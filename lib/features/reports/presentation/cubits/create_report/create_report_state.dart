import 'package:equatable/equatable.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';

class CreateReportState extends Equatable {
  final String title;
  final String description;
  final String? categoryId;
  final ReportPriorityEnum priority;
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const CreateReportState({
    this.title = '',
    this.description = '',
    this.categoryId,
    this.priority = ReportPriorityEnum.normal,
    this.imagePath,
    this.latitude,
    this.longitude,
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

  CreateReportState copyWith({
    String? title,
    String? description,
    String? categoryId,
    ReportPriorityEnum? priority,
    String? imagePath,
    double? latitude,
    double? longitude,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return CreateReportState(
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      imagePath: imagePath ?? this.imagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    categoryId,
    priority,
    imagePath,
    latitude,
    longitude,
    isSubmitting,
    isSuccess,
    errorMessage,
  ];
}
