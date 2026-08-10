import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:spora_app/features/reports/domain/models/local_report_model.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';
import 'package:spora_app/features/reports/domain/repositories/report_repository.dart';
import 'package:spora_app/features/reports/presentation/cubits/edit_report/edit_report_cubit.dart';

class FakeReportRepository implements ReportRepository {
  FakeReportRepository(this.report);

  LocalReportModel report;
  LocalReportModel? updatedReport;
  String? submittedId;

  @override
  Future<void> createReport(LocalReportModel report) async {}

  @override
  Future<void> deleteReport(String localId) async {}

  @override
  Future<List<LocalReportModel>> getAllReports() async => [report];

  @override
  Future<void> submitReport(String localId) async {
    submittedId = localId;
  }

  @override
  Future<void> syncAllReports() async {}

  @override
  Future<void> updateReport(LocalReportModel report) async {
    updatedReport = report;
    this.report = report;
  }
}

LocalReportModel buildReport({String? imagePath}) {
  return LocalReportModel(
    localId: 'local-1',
    title: 'Broken water pipe',
    description: 'Water is leaking in the main hall',
    categoryId: 'technical',
    priority: ReportPriorityEnum.high,
    imagePath: imagePath,
    status: ReportStatusEnum.failed,
    lastError: 'validation_error',
    createdAt: DateTime(2026, 1, 1, 10, 0),
    updatedAt: DateTime(2026, 1, 1, 10, 0),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;
  late Directory documentsDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('spora_edit_report_test_');
    documentsDir = Directory(p.join(tempDir.path, 'documents'));
    await documentsDir.create();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return documentsDir.path;
          }
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);

    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('replacing an image during edit copies it to persistent storage',
      () async {
    final originalImage = File(p.join(tempDir.path, 'old-photo.jpg'));
    final replacementImage = File(p.join(tempDir.path, 'new-photo.jpg'));
    await originalImage.writeAsString('old image');
    await replacementImage.writeAsString('new image');

    final repository = FakeReportRepository(
      buildReport(imagePath: originalImage.path),
    );
    final cubit = EditReportCubit(repository: repository)
      ..loadReport(repository.report)
      ..imageSelected(replacementImage.path);

    await cubit.updateReport();

    final savedPath = repository.updatedReport?.imagePath;
    expect(savedPath, isNotNull);
    expect(savedPath, isNot(replacementImage.path));
    expect(p.dirname(savedPath!), documentsDir.path);
    expect(await File(savedPath).readAsString(), 'new image');
    expect(repository.submittedId, 'local-1');

    await cubit.close();
  });
}
