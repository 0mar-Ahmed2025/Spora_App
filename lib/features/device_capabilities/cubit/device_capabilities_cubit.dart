import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

import '../models/location_data_model.dart';
import '../services/audio_recorder_service.dart';
import '../services/camera_gallery_service.dart';
import '../services/file_picker_service.dart';
import '../services/location_service.dart';
import '../services/map_launcher_service.dart';
import '../services/permission_service.dart';
import 'device_capabilities_state.dart';

class DeviceCapabilitiesCubit extends Cubit<DeviceCapabilitiesState> {
  final PermissionService _permissionService;
  final CameraGalleryService _cameraGalleryService;
  final LocationService _locationService;
  final MapLauncherService _mapLauncherService;
  final FilePickerService _filePickerService;
  final AudioRecorderService _audioRecorderService;

  LocationDataModel? _lastRetrievedLocation;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  DeviceCapabilitiesCubit({
    required PermissionService permissionService,
    required CameraGalleryService cameraGalleryService,
    required LocationService locationService,
    required MapLauncherService mapLauncherService,
    required FilePickerService filePickerService,
    required AudioRecorderService audioRecorderService,
  }) : _permissionService = permissionService,
       _cameraGalleryService = cameraGalleryService,
       _locationService = locationService,
       _mapLauncherService = mapLauncherService,
       _filePickerService = filePickerService,
       _audioRecorderService = audioRecorderService,
       super(DeviceCapabilitiesInitial());

  LocationDataModel? get lastRetrievedLocation => _lastRetrievedLocation;

  // --- 1. الكاميرا ----------------------------------------------------------------------
  Future<void> openCamera() async {
    final status = await _handlePermission(Permission.camera);
    if (!status) return;

    emit(DeviceCapabilitiesLoading());
    try {
      final file = await _cameraGalleryService.capturePhoto();
      if (file != null) {
        emit(DeviceMediaSuccess(file));
      } else {
        emit(DeviceOperationCancelled());
      }
    } catch (e) {
      emit(
        const DeviceCapabilitiesError(
          LocaleKeys.device_capabilities_error_occurred,
        ),
      );
    }
  }

  // --- 2. المعرض ----------------------------------------------------------------------
  Future<void> selectFromGallery() async {
    final permission = Permission.photos;
    final status = await _handlePermission(permission);
    if (!status) return;

    emit(DeviceCapabilitiesLoading());
    try {
      final file = await _cameraGalleryService.pickImageFromGallery();
      if (file != null) {
        emit(DeviceMediaSuccess(file));
      } else {
        emit(DeviceOperationCancelled());
      }
    } catch (e) {
      emit(
        const DeviceCapabilitiesError(
          LocaleKeys.device_capabilities_error_occurred,
        ),
      );
    }
  }

  // --- 3. الموقع الجغرافي ----------------------------------------------------------------------
  Future<void> getCurrentLocation() async {
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(DeviceServiceDisabledState());
      return;
    }

    final status = await _handlePermission(Permission.location);
    if (!status) return;

    emit(DeviceCapabilitiesLoading());
    try {
      final locationData = await _locationService.getCurrentLocation();
      _lastRetrievedLocation = locationData;
      emit(DeviceLocationSuccess(locationData));
    } on TimeoutException {
      emit(
        const DeviceCapabilitiesError(
          LocaleKeys.device_capabilities_location_timeout_msg,
        ),
      );
    } catch (e) {
      emit(
        const DeviceCapabilitiesError(
          LocaleKeys.device_capabilities_error_occurred,
        ),
      );
    }
  }

  // --- 4. الخريطة الخارجية ----------------------------------------------------------------------
  Future<void> openExternalMap() async {
    if (_lastRetrievedLocation == null) {
      emit(
        DeviceCapabilitiesError(
          LocaleKeys.device_capabilities_no_location_yet_msg,
        ),
      );
      return;
    }

    final launched = await _mapLauncherService.openMap(
      _lastRetrievedLocation!.latitude,
      _lastRetrievedLocation!.longitude,
    );

    if (!launched) {
      emit(
        const DeviceCapabilitiesError(
          LocaleKeys.device_capabilities_no_map_app_msg,
        ),
      );
    }
  }

  // --- 5. اختيار ملف ----------------------------------------------------------------------
  Future<void> pickFile() async {
    emit(DeviceCapabilitiesLoading());
    try {
      final file = await _filePickerService.pickSingleFile();
      if (file != null) {
        emit(DeviceMediaSuccess(file));
      } else {
        emit(DeviceOperationCancelled());
      }
    } catch (e) {
      emit(
        const DeviceCapabilitiesError(
          LocaleKeys.device_capabilities_error_occurred,
        ),
      );
    }
  }

  // --- 6. تسجيل الصوت ----------------------------------------------------------------------
  Future<void> startAudioRecording() async {
    if (_isRecording) return;

    final status = await _handlePermission(Permission.microphone);
    if (!status) return;

    _isRecording = true;
    _recordingSeconds = 0;
    emit(const DeviceAudioRecordingInProgress(durationInSeconds: 0));

    try {
      await _audioRecorderService.startRecording();

      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingSeconds++;
        emit(
          DeviceAudioRecordingInProgress(durationInSeconds: _recordingSeconds),
        );
      });
    } catch (e) {
      _isRecording = false;
      _recordingTimer?.cancel();
      emit(
        DeviceCapabilitiesError(LocaleKeys.device_capabilities_error_occurred),
      );
    }
  }

  Future<void> stopAudioRecording() async {
    if (!_isRecording) return;

    _recordingTimer?.cancel();
    try {
      final audioFile = await _audioRecorderService.stopRecording();
      _isRecording = false;
      if (audioFile != null) {
        emit(DeviceAudioRecordSuccess(audioFile));
      } else {
        emit(DeviceOperationCancelled());
      }
    } catch (e) {
      _isRecording = false;
      emit(
        DeviceCapabilitiesError(LocaleKeys.device_capabilities_error_occurred),
      );
    }
  }

  Future<void> cancelAudioRecording() async {
    if (!_isRecording) return;

    _recordingTimer?.cancel();
    _isRecording = false;
    await _audioRecorderService.cancelRecording();
    emit(DeviceOperationCancelled());
  }

  // --- إدارة الصلاحيات العامّة ----------------------------------------------------------------------
  Future<bool> _handlePermission(Permission permission) async {
    var status = await _permissionService.checkPermission(permission);

    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await _permissionService.requestPermission(permission);
      if (status.isGranted) return true;
    }

    if (status.isPermanentlyDenied) {
      emit(DevicePermissionPermanentlyDenied(permission));
      return false;
    }

    if (status.isDenied) {
      emit(DevicePermissionDenied(permission));
      return false;
    }

    return false;
  }

  Future<void> openAppSettings() async {
    await _permissionService.openSettings();
  }

  @override
  Future<void> close() async {
    _recordingTimer?.cancel();

    if (_isRecording) {
      try {
        await _audioRecorderService.cancelRecording();
      } catch (_) {}
      _isRecording = false;
    }

    await _audioRecorderService.dispose();

    return super.close();
  }
}
