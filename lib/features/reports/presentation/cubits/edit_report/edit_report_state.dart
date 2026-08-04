import 'package:equatable/equatable.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';

class EditReportState extends Equatable {
  final String? localId;
  final String title;
  final String description;
  final String? categoryId;
  final ReportPriorityEnum priority;
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final ReportStatusEnum originalStatus;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const EditReportState({
    this.localId,
    this.title = '',
    this.description = '',
    this.categoryId,
    this.priority = ReportPriorityEnum.normal,
    this.imagePath,
    this.latitude,
    this.longitude,
    this.originalStatus = ReportStatusEnum.draft,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  bool get isTitleValid =>
      title.trim().length >= 3 && title.trim().length <= 80;
  bool get isDescriptionValid =>
      description.trim().length >= 10 && description.trim().length <= 500;
  bool get isCategoryValid => categoryId != null && categoryId!.isNotEmpty;
  bool get isValid => isTitleValid && isDescriptionValid && isCategoryValid;

  EditReportState copyWith({
    String? title,
    String? description,
    String? categoryId,
    ReportPriorityEnum? priority,
    String? imagePath,
    double? latitude,
    double? longitude,
    bool clearLocation = false,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return EditReportState(
      localId: localId,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      imagePath: imagePath ?? this.imagePath,
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
      originalStatus: originalStatus,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    localId,
    title,
    description,
    categoryId,
    priority,
    imagePath,
    latitude,
    longitude,
    originalStatus,
    isSubmitting,
    isSuccess,
    errorMessage,
  ];
}
