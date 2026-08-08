import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:spora_app/core/database/database_helper.dart';
import 'package:spora_app/core/errors/failures.dart';
import 'package:spora_app/features/reports/data/datasources/fake_report_remote_data_source.dart';
import 'package:spora_app/features/reports/data/datasources/local_report_data_source.dart';
import 'package:spora_app/features/reports/domain/models/local_report_model.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';
import 'package:spora_app/features/reports/domain/repositories/report_repository_impl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TestReportRemoteDataSource extends FakeReportRemoteDataSourceImpl {
  TestReportRemoteDataSource({super.mode, this.delay, this.failure, this.serverId});

  int submitCalls = 0;
  final List<String> idempotencyKeys = [];
  final Duration? delay;
  final Failure? failure;
  final String? serverId;

  @override
  Future<String> submitReport(
    LocalReportModel report, {
    required String idempotencyKey,
  }) async {
    submitCalls++;
    idempotencyKeys.add(idempotencyKey);
    if (delay != null) {
      await Future.delayed(delay!);
    }
    if (failure != null) throw failure!;
    if (serverId != null) return serverId!;
    return super.submitReport(report, idempotencyKey: idempotencyKey);
  }
}

LocalReportModel buildReport({
  String localId = 'local-1',
  ReportStatusEnum status = ReportStatusEnum.queued,
  String? imagePath,
  String? lastError,
  int retryCount = 0,
}) {
  return LocalReportModel(
    localId: localId,
    title: 'Broken water pipe',
    description: 'Water is leaking in the main hall',
    categoryId: 'technical',
    priority: ReportPriorityEnum.high,
    imagePath: imagePath,
    status: status,
    lastError: lastError,
    retryCount: retryCount,
    createdAt: DateTime(2026, 1, 1, 10, 0),
    updatedAt: DateTime(2026, 1, 1, 10, 0),
  );
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late String dbPath;

  setUp(() async {
    dbPath = p.join(
      Directory.systemTemp.path,
      'test_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    await DatabaseHelper.resetForTesting(databasePath: dbPath);
  });

  tearDown(() async {
    await DatabaseHelper.resetForTesting(databasePath: null);
    final file = File(dbPath);
    if (file.existsSync()) {
      file.deleteSync();
    }
  });

  group('createReport', () {
    test('saves a valid report locally and keeps it in the queue on failure',
        () async {
      final remote = TestReportRemoteDataSource(
        mode: FakeServiceMode.offline,
      );
      final repo = ReportRepositoryImpl(
        localDataSource: LocalReportDataSourceImpl(),
        remoteDataSource: remote,
      );

      await repo.createReport(buildReport());

      final reports = await repo.getAllReports();
      expect(reports, hasLength(1));
      expect(reports.first.localId, 'local-1');
      expect(reports.first.title, 'Broken water pipe');
      expect(reports.first.status, ReportStatusEnum.failed);
      expect(reports.first.retryCount, 1);
      expect(reports.first.lastError, 'network_unavailable');
    });

    test('restores saved reports after repository reinitialization', () async {
      final repo1 = ReportRepositoryImpl(
        localDataSource: LocalReportDataSourceImpl(),
        remoteDataSource: TestReportRemoteDataSource(
          mode: FakeServiceMode.offline,
        ),
      );
      await repo1.createReport(buildReport(localId: 'local-1'));

      await DatabaseHelper.resetForTesting(databasePath: dbPath);

      final repo2 = ReportRepositoryImpl(
        localDataSource: LocalReportDataSourceImpl(),
        remoteDataSource: TestReportRemoteDataSource(
          mode: FakeServiceMode.offline,
        ),
      );
      final reports = await repo2.getAllReports();

      expect(reports, hasLength(1));
      expect(reports.first.localId, 'local-1');
      expect(reports.first.title, 'Broken water pipe');
    });

    test('does not auto-submit drafts', () async {
      final remote = TestReportRemoteDataSource();
      final repo = ReportRepositoryImpl(
        localDataSource: LocalReportDataSourceImpl(),
        remoteDataSource: remote,
      );

      await repo.createReport(buildReport(status: ReportStatusEnum.draft));

      expect(remote.submitCalls, 0);
      final reports = await repo.getAllReports();
      expect(reports.single.status, ReportStatusEnum.draft);
    });
  });

  group('submitReport', () {
    test('marks report submitted with server id on success', () async {
      final remote = TestReportRemoteDataSource(serverId: 'SERVER_abc');
      final repo = ReportRepositoryImpl(
        localDataSource: LocalReportDataSourceImpl(),
        remoteDataSource: remote,
      );
      await repo.createReport(buildReport());

      final reports = await repo.getAllReports();
      expect(reports.single.status, ReportStatusEnum.submitted);
      expect(reports.single.serverId, 'SERVER_abc');
      expect(reports.single.lastError, isNull);
      expect(reports.single.retryCount, 0);
      expect(remote.idempotencyKeys.single, 'local-1');
    });

    test('marks report failed and increments retry count on network failure',
        () async {
      final remote = TestReportRemoteDataSource(
        mode: FakeServiceMode.offline,
      );
      final repo = ReportRepositoryImpl(
        localDataSource: LocalReportDataSourceImpl(),
        remoteDataSource: remote,
      );
      await repo.createReport(buildReport());

      final reports = await repo.getAllReports();
      expect(reports.single.status, ReportStatusEnum.failed);
      expect(reports.single.retryCount, 1);
      expect(reports.single.lastError, 'network_unavailable');
    });

    test('increments retry count across retries', () async {
      final remote = TestReportRemoteDataSource(
        mode: FakeServiceMode.offline,
      );
      final repo = ReportRepositoryImpl(
        localDataSource: LocalReportDataSourceImpl(),
        remoteDataSource: remote,
      );
      await repo.createReport(buildReport());
      await repo.submitReport('local-1');

      final reports = await repo.getAllReports();
      expect(reports.single.retryCount, 2);
      expect(remote.submitCalls, 2);
    });

    test('prevents duplicate simultaneous submissions', () async {
      final remote = TestReportRemoteDataSource(
        delay: const Duration(milliseconds: 50),
      );
      final repo = ReportRepositoryImpl(
        localDataSource: LocalReportDataSourceImpl(),
        remoteDataSource: remote,
      );

      await repo.createReport(buildReport(status: ReportStatusEnum.draft));

      final results = await Future.wait([
        repo.submitReport('local-1'),
        repo.submitReport('local-1'),
      ]);
      expect(results, hasLength(2));

      expect(remote.submitCalls, 1);
      final reports = await repo.getAllReports();
      expect(reports.single.status, ReportStatusEnum.submitted);
    });

    test('handles missing image file safely', () async {
      final remote = TestReportRemoteDataSource();
      final repo = ReportRepositoryImpl(
        localDataSource: LocalReportDataSourceImpl(),
        remoteDataSource: remote,
      );
      await repo.createReport(
        buildReport(
          imagePath: p.join(Directory.systemTemp.path, 'missing_photo.jpg'),
          status: ReportStatusEnum.draft,
        ),
      );

      await repo.submitReport('local-1');

      final reports = await repo.getAllReports();
      expect(reports.single.status, ReportStatusEnum.failed);
      expect(reports.single.lastError, 'file_missing');
      expect(remote.submitCalls, 0);
    });
  });

  group('syncAllReports', () {
    test('does not retry validation errors', () async {
      final remote = TestReportRemoteDataSource(
        mode: FakeServiceMode.validationError,
      );
      final repo = ReportRepositoryImpl(
        localDataSource: LocalReportDataSourceImpl(),
        remoteDataSource: remote,
      );
      await repo.createReport(buildReport());

      await repo.syncAllReports();

      final reports = await repo.getAllReports();
      expect(reports.single.status, ReportStatusEnum.failed);
      expect(reports.single.lastError, 'validation_error');
      expect(remote.submitCalls, 1);
    });

    test('submits only eligible queued and retryable reports', () async {
      final local = LocalReportDataSourceImpl();
      final remote = TestReportRemoteDataSource();
      final repo = ReportRepositoryImpl(
        localDataSource: local,
        remoteDataSource: remote,
      );

      await local.insertReport(
        buildReport(
          localId: 'queued-1',
          status: ReportStatusEnum.queued,
        ),
      );
      await local.insertReport(
        buildReport(
          localId: 'failed-network',
          status: ReportStatusEnum.failed,
          lastError: 'network_unavailable',
          retryCount: 1,
        ),
      );
      await local.insertReport(
        buildReport(
          localId: 'failed-validation',
          status: ReportStatusEnum.failed,
          lastError: 'validation_error',
          retryCount: 1,
        ),
      );
      await local.insertReport(
        buildReport(
          localId: 'submitted-1',
          status: ReportStatusEnum.submitted,
          lastError: null,
        ),
      );
      await local.insertReport(
        buildReport(
          localId: 'draft-1',
          status: ReportStatusEnum.draft,
        ),
      );

      await repo.syncAllReports();

      expect(remote.submitCalls, 2);
      final byId = {
        for (final r in await repo.getAllReports()) r.localId: r,
      };
      expect(byId['queued-1']!.status, ReportStatusEnum.submitted);
      expect(byId['failed-network']!.status, ReportStatusEnum.submitted);
      expect(byId['failed-validation']!.status, ReportStatusEnum.failed);
      expect(byId['failed-validation']!.lastError, 'validation_error');
      expect(byId['submitted-1']!.status, ReportStatusEnum.submitted);
      expect(byId['draft-1']!.status, ReportStatusEnum.draft);
    });
  });
}
