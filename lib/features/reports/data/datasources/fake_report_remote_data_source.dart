import 'package:spora_app/core/errors/failures.dart';
import 'package:spora_app/features/reports/domain/models/local_report_model.dart';

enum FakeServiceMode { success, offline, timeout, serverError, validationError }

abstract interface class ReportRemoteDataSource {
  Future<String> submitReport(
    LocalReportModel report, {
    required String idempotencyKey,
  });
}

final sharedFakeRemoteDataSource = FakeReportRemoteDataSourceImpl();

class FakeReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  FakeServiceMode mode;

  FakeReportRemoteDataSourceImpl({this.mode = FakeServiceMode.success});

  @override
  Future<String> submitReport(
    LocalReportModel report, {
    required String idempotencyKey,
  }) async {
    switch (mode) {
      case FakeServiceMode.success:
        await Future.delayed(const Duration(seconds: 1));
        return 'SERVER_${DateTime.now().millisecondsSinceEpoch}';

      case FakeServiceMode.offline:
        throw const NetworkFailure();

      case FakeServiceMode.timeout:
        await Future.delayed(const Duration(seconds: 3));
        throw const TimeoutFailure();

      case FakeServiceMode.serverError:
        await Future.delayed(const Duration(milliseconds: 500));
        throw const ServerFailure();

      case FakeServiceMode.validationError:
        await Future.delayed(const Duration(milliseconds: 500));
        throw const ValidationFailure();
    }
  }
}
