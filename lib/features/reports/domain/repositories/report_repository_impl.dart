import 'dart:async';
import 'package:spora_app/core/errors/failures.dart';
import 'package:spora_app/core/utils/file_helper.dart';
import 'package:spora_app/features/reports/data/datasources/fake_report_remote_data_source.dart';
import 'package:spora_app/features/reports/data/datasources/local_report_data_source.dart';
import 'package:spora_app/features/reports/domain/models/local_report_model.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';
import 'package:spora_app/features/reports/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final LocalReportDataSource _localDataSource; // Local database
  final ReportRemoteDataSource _remoteDataSource; // Server-side
  final Set<String> _processingIds = {};

  ReportRepositoryImpl({
    required LocalReportDataSource localDataSource,
    required ReportRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<void> createReport(LocalReportModel report) async {
    final permanentImagePath = await FileHelper.saveImagePermanently(
      report.imagePath,
    );

    final reportToSave = report.copyWith(imagePath: permanentImagePath);

    await _localDataSource.insertReport(reportToSave);

    if (reportToSave.status == ReportStatusEnum.queued) {
      await submitReport(reportToSave.localId);
    }
  }

  @override
  Future<void> submitReport(String localId) async {
    if (!_processingIds.add(localId)) {
      return;
    }

    try {
      final report = await _localDataSource.getReportById(localId);
      if (report == null) return;
      if (report.status == ReportStatusEnum.failed &&
          report.lastError == 'validation_error') {
        return;
      }

      if (report.imagePath != null) {
        final exists = await FileHelper.isFileAvailable(report.imagePath);
        if (!exists) {
          final updatedReport = report.copyWith(
            status: ReportStatusEnum.failed,
            lastError: 'file_missing',
            updatedAt: DateTime.now(),
          );
          await _localDataSource.updateReport(updatedReport);
          return;
        }
      }

      final sendingReport = report.copyWith(
        status: ReportStatusEnum.sending,
        updatedAt: DateTime.now(),
      );
      await _localDataSource.updateReport(sendingReport);

      try {
        final serverId = await _remoteDataSource.submitReport(
          sendingReport,
          idempotencyKey: sendingReport.localId,
        );

        final submittedReport = sendingReport.copyWith(
          serverId: serverId,
          status: ReportStatusEnum.submitted,
          lastError: null,
          updatedAt: DateTime.now(),
        );
        await _localDataSource.updateReport(submittedReport);
      } on Failure catch (e) {
        final updatedReport = sendingReport.copyWith(
          status: ReportStatusEnum.failed,
          retryCount: sendingReport.retryCount + 1,
          lastError: e.code,
          updatedAt: DateTime.now(),
        );
        await _localDataSource.updateReport(updatedReport);
      } catch (e) {
        final updatedReport = sendingReport.copyWith(
          status: ReportStatusEnum.failed,
          retryCount: sendingReport.retryCount + 1,
          lastError: 'unknown_error',
          updatedAt: DateTime.now(),
        );
        await _localDataSource.updateReport(updatedReport);
      }
    } finally {
      _processingIds.remove(localId);
    }
  }

  @override
  Future<void> syncAllReports() async {
    final reports = await _localDataSource.getAllReports();
    final pendingReports = reports.where((r) {
      if (r.status == ReportStatusEnum.draft) return false;
      if (r.status == ReportStatusEnum.submitted) return false;
      if (r.status == ReportStatusEnum.sending) return false;
      if (r.lastError == 'validation_error') return false;
      return true;
    }).toList();

    for (final report in pendingReports) {
      await submitReport(report.localId);
    }
  }

  @override
  Future<void> updateReport(LocalReportModel report) async {
    final oldReport = await _localDataSource.getReportById(report.localId);

    final updatedReport = report.copyWith(updatedAt: DateTime.now());

    await _localDataSource.updateReport(updatedReport);

    if (oldReport != null &&
        oldReport.imagePath != null &&
        oldReport.imagePath != updatedReport.imagePath) {
      await FileHelper.deleteFile(oldReport.imagePath);
    }
  }

  @override
  Future<void> deleteReport(String localId) async {
    final report = await _localDataSource.getReportById(localId);

    if (report == null) return;

    await _localDataSource.deleteReport(localId);

    await FileHelper.deleteFile(report.imagePath);
  }

  @override
  Future<List<LocalReportModel>> getAllReports() async {
    return await _localDataSource.getAllReports();
  }
}
