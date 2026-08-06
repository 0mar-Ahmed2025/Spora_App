import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/features/reports/domain/models/local_report_model.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';
import 'package:spora_app/features/reports/domain/repositories/report_repository.dart';
import 'package:spora_app/features/reports/presentation/cubits/create_report/create_report_state.dart';
import 'package:uuid/uuid.dart';

class CreateReportCubit extends Cubit<CreateReportState> {
  final ReportRepository _repository;
  final Uuid _uuid;

  CreateReportCubit({required ReportRepository repository, Uuid? uuid})
    : _repository = repository,
      _uuid = uuid ?? const Uuid(),
      super(const CreateReportState());

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

  void locationFetched(double lat, double lng) {
    emit(state.copyWith(latitude: lat, longitude: lng));
  }

  void locationCleared() {
    emit(state.copyWith(clearLocation: true));
  }

  Future<void> submitReport({required bool saveAsDraft}) async {
  if (!saveAsDraft && !state.isValid) return;
  if (state.isSubmitting) return;

  emit(state.copyWith(isSubmitting: true, errorMessage: null));

  try {
    final now = DateTime.now();
    final status = saveAsDraft ? ReportStatusEnum.draft : ReportStatusEnum.queued;

    final newReport = LocalReportModel(
      localId: _uuid.v4(),
      title: state.title.trim(),
      description: state.description.trim(),
      categoryId: state.categoryId ?? 'technical',
      priority: state.priority,
      imagePath: state.imagePath,
      latitude: state.latitude,
      longitude: state.longitude,
      status: status,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.createReport(newReport);


    emit(state.copyWith(isSubmitting: false, isSuccess: true));
  } catch (e) {
    emit(state.copyWith(isSubmitting: false, errorMessage: 'storage_error'));
  }
}





}
