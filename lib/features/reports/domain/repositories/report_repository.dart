import 'package:spora_app/features/reports/domain/models/local_report_model.dart';

abstract interface class ReportRepository {
  Future<void> createReport(LocalReportModel report);
  Future<void> submitReport(String localId);
  Future<void> syncAllReports();
  Future<void> updateReport(LocalReportModel report);
  Future<void> deleteReport(String localId);
  Future<List<LocalReportModel>> getAllReports();
}
