import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/features/reports/domain/models/local_report_model.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';
import 'package:spora_app/features/reports/domain/repositories/report_repository.dart';
import 'package:spora_app/features/reports/presentation/cubits/edit_report/edit_report_state.dart';

class EditReportCubit extends Cubit<EditReportState> {
  final ReportRepository _repository;

  EditReportCubit({required ReportRepository repository})
    : _repository = repository,
      super(const EditReportState());

  void loadReport(LocalReportModel report) {
    emit(
      EditReportState(
        localId: report.localId,
        title: report.title,
        description: report.description,
        categoryId: report.categoryId,
        priority: report.priority,
        imagePath: report.imagePath,
        latitude: report.latitude,
        longitude: report.longitude,
        originalStatus: report.status,
      ),
    );
  }

  void titleChanged(String value) {
    emit(state.copyWith(title: value));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  void categoryChanged(String categoryId) {
    emit(state.copyWith(categoryId: categoryId));
  }

  void priorityChanged(ReportPriorityEnum priority) {
    emit(state.copyWith(priority: priority));
  }

  void imageSelected(String? path) {
    emit(state.copyWith(imagePath: path));
  }

  void locationCleared() {
    emit(state.copyWith(clearLocation: true));
  }

  void updateLocation(double lat, double lng) {
    emit(state.copyWith(latitude: lat, longitude: lng));
  }

  Future<void> updateReport() async {
    if (!state.isValid || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final existingReport = await _repository.getAllReports();
      final report = existingReport.firstWhere(
        (r) => r.localId == state.localId,
      );

      final updatedReport = report.copyWith(
        title: state.title.trim(),
        description: state.description.trim(),
        categoryId: state.categoryId!,
        priority: state.priority,
        imagePath: state.imagePath,
        latitude: state.latitude,
        longitude: state.longitude,
        status: ReportStatusEnum.queued,
        lastError: null,
        updatedAt: DateTime.now(),
      );

      await _repository.updateReport(updatedReport);

      await _repository.submitReport(updatedReport.localId);

      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: 'storage_error'));
    }
  }
}
