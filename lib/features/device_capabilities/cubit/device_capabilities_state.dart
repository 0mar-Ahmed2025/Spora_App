import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spora_app/features/device_capabilities/models/location_data_model.dart';
import 'package:spora_app/features/device_capabilities/models/media_file_model.dart';

abstract class DeviceCapabilitiesState extends Equatable {
  const DeviceCapabilitiesState();

  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية
class DeviceCapabilitiesInitial extends DeviceCapabilitiesState {}

/// حالة تحميل أو معالجة دائرية
class DeviceCapabilitiesLoading extends DeviceCapabilitiesState {}

/// حالة نجاح التقاط/اختيار صورة أو ملف
class DeviceMediaSuccess extends DeviceCapabilitiesState {
  final MediaFileModel mediaFile;

  const DeviceMediaSuccess(this.mediaFile);

  @override
  List<Object?> get props => [mediaFile];
}

/// حالة نجاح جلب الموقع الجغرافي
class DeviceLocationSuccess extends DeviceCapabilitiesState {
  final LocationDataModel locationData;

  const DeviceLocationSuccess(this.locationData);

  @override
  List<Object?> get props => [locationData];
}

/// حالة التسجيل الصوتي الجاري
class DeviceAudioRecordingInProgress extends DeviceCapabilitiesState {
  final int durationInSeconds;

  const DeviceAudioRecordingInProgress({required this.durationInSeconds});

  @override
  List<Object?> get props => [durationInSeconds];
}

/// حالة نجاح تسجيل الصوت
class DeviceAudioRecordSuccess extends DeviceCapabilitiesState {
  final MediaFileModel audioFile;

  const DeviceAudioRecordSuccess(this.audioFile);

  @override
  List<Object?> get props => [audioFile];
}

/// حالة رفض الصلاحية مؤقتاً
class DevicePermissionDenied extends DeviceCapabilitiesState {
  final Permission permission;

  const DevicePermissionDenied(this.permission);

  @override
  List<Object?> get props => [permission];
}

/// حالة رفض الصلاحية بشكل دائم (تتطلب فتح الإعدادات)
class DevicePermissionPermanentlyDenied extends DeviceCapabilitiesState {
  final Permission permission;

  const DevicePermissionPermanentlyDenied(this.permission);

  @override
  List<Object?> get props => [permission];
}

/// حالة إيقاف الخدمة (مثل الـ GPS معطل)
class DeviceServiceDisabledState extends DeviceCapabilitiesState {}

/// حالة إلغاء العملية بواسطة المستخدم
class DeviceOperationCancelled extends DeviceCapabilitiesState {}

/// حالة حدوث خطأ
class DeviceCapabilitiesError extends DeviceCapabilitiesState {
  final String messageKey;

  const DeviceCapabilitiesError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}
