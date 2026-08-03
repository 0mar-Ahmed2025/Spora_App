import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/features/reports/data/datasources/fake_report_remote_data_source.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';
import 'package:spora_app/features/reports/domain/repositories/report_repository.dart';

import 'report_queue_state.dart';

class ReportQueueCubit extends Cubit<ReportQueueState> {
  final ReportRepository _repository;
  final FakeReportRemoteDataSourceImpl _remoteDataSource;

  ReportQueueCubit({
    required ReportRepository repository,
    required FakeReportRemoteDataSourceImpl remoteDataSource,
  }) : _repository = repository,
       _remoteDataSource = remoteDataSource,
       super(const ReportQueueState());

  Future<void> loadReports() async {
    emit(state.copyWith(isLoading: true));
    final reports = await _repository.getAllReports();
    emit(state.copyWith(allReports: reports, isLoading: false));
  }

  Future<void> retryReport(String localId) async {
    await _repository.submitReport(localId);
    await loadReports();
  }

  Future<void> syncAll() async {
    emit(state.copyWith(isLoading: true));
    await _repository.syncAllReports();
    await loadReports();
  }

  Future<void> deleteDraft(String localId) async {
    await _repository.deleteReport(localId);
    await loadReports();
  }

  void setFilter(ReportStatusEnum? status) {
    if (status == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(filterStatus: status));
    }
  }

  void changeFakeServiceMode(FakeServiceMode mode) {
    _remoteDataSource.mode = mode;
    emit(state.copyWith(fakeServiceMode: mode));
  }
}
