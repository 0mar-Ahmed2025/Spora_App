import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:spora_app/features/device_capabilities/cubit/device_capabilities_cubit.dart';
import 'package:spora_app/features/device_capabilities/cubit/device_capabilities_state.dart';
import 'package:spora_app/features/device_capabilities/models/location_data_model.dart';
import 'package:spora_app/features/device_capabilities/models/media_file_model.dart';
import 'package:spora_app/features/device_capabilities/services/audio_recorder_service.dart';
import 'package:spora_app/features/device_capabilities/services/camera_gallery_service.dart';
import 'package:spora_app/features/device_capabilities/services/file_picker_service.dart';
import 'package:spora_app/features/device_capabilities/services/location_service.dart';
import 'package:spora_app/features/device_capabilities/services/map_launcher_service.dart';
import 'package:spora_app/features/device_capabilities/services/permission_service.dart';

class MockPermissionService extends Mock implements PermissionService {}

class MockCameraGalleryService extends Mock implements CameraGalleryService {}

class MockLocationService extends Mock implements LocationService {}

class MockMapLauncherService extends Mock implements MapLauncherService {}

class MockFilePickerService extends Mock implements FilePickerService {}

class MockAudioRecorderService extends Mock implements AudioRecorderService {
  @override
  Future<void> dispose() async {}
}

void main() {
  late DeviceCapabilitiesCubit cubit;
  late MockPermissionService mockPermissionService;
  late MockCameraGalleryService mockCameraGalleryService;
  late MockLocationService mockLocationService;
  late MockMapLauncherService mockMapLauncherService;
  late MockFilePickerService mockFilePickerService;
  late MockAudioRecorderService mockAudioRecorderService;

  setUp(() {
    mockPermissionService = MockPermissionService();
    mockCameraGalleryService = MockCameraGalleryService();
    mockLocationService = MockLocationService();
    mockMapLauncherService = MockMapLauncherService();
    mockFilePickerService = MockFilePickerService();
    mockAudioRecorderService = MockAudioRecorderService();
    cubit = DeviceCapabilitiesCubit(
      permissionService: mockPermissionService,
      cameraGalleryService: mockCameraGalleryService,
      locationService: mockLocationService,
      mapLauncherService: mockMapLauncherService,
      filePickerService: mockFilePickerService,
      audioRecorderService: mockAudioRecorderService,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('Camera Tests', () {
    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'emits [DeviceCapabilitiesLoading, DeviceMediaSuccess] when camera captures photo successfully',
      build: () {
        when(
          () => mockPermissionService.checkPermission(Permission.camera),
        ).thenAnswer((_) async => PermissionStatus.granted);
        when(() => mockCameraGalleryService.capturePhoto()).thenAnswer(
          (_) async => const MediaFileModel(
            name: 'test.jpg',
            path: '/path/test.jpg',
            sizeInBytes: 1024,
            fileType: 'jpg',
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.openCamera(),
      expect: () => [
        isA<DeviceCapabilitiesLoading>(),
        isA<DeviceMediaSuccess>(),
      ],
    );

    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'emits [DeviceOperationCancelled] when user cancels camera',
      build: () {
        when(
          () => mockPermissionService.checkPermission(Permission.camera),
        ).thenAnswer((_) async => PermissionStatus.granted);
        when(
          () => mockCameraGalleryService.capturePhoto(),
        ).thenAnswer((_) async => null);
        return cubit;
      },
      act: (cubit) => cubit.openCamera(),
      expect: () => [
        isA<DeviceCapabilitiesLoading>(),
        isA<DeviceOperationCancelled>(),
      ],
    );
  });

  group('Permission Tests', () {
    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'emits [DevicePermissionPermanentlyDenied] when camera permission is permanently denied',
      build: () {
        when(
          () => mockPermissionService.checkPermission(Permission.camera),
        ).thenAnswer((_) async => PermissionStatus.permanentlyDenied);
        return cubit;
      },
      act: (cubit) => cubit.openCamera(),
      expect: () => [isA<DevicePermissionPermanentlyDenied>()],
    );

    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'emits [DevicePermissionDenied] when camera permission is temporarily denied after request',
      build: () {
        when(
          () => mockPermissionService.checkPermission(Permission.camera),
        ).thenAnswer((_) async => PermissionStatus.denied);
        when(
          () => mockPermissionService.requestPermission(Permission.camera),
        ).thenAnswer((_) async => PermissionStatus.denied);
        return cubit;
      },
      act: (cubit) => cubit.openCamera(),
      expect: () => [isA<DevicePermissionDenied>()],
    );
  });

  group('File Picker Tests', () {
    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'emits [DeviceOperationCancelled] when file picker is cancelled',
      build: () {
        when(
          () => mockFilePickerService.pickSingleFile(),
        ).thenAnswer((_) async => null);
        return cubit;
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        isA<DeviceCapabilitiesLoading>(),
        isA<DeviceOperationCancelled>(),
      ],
    );

    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'emits [DeviceMediaSuccess] when a file is picked',
      build: () {
        when(() => mockFilePickerService.pickSingleFile()).thenAnswer(
          (_) async => const MediaFileModel(
            name: 'doc.pdf',
            path: '/path/doc.pdf',
            sizeInBytes: 2048,
            fileType: 'pdf',
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.pickFile(),
      expect: () => [
        isA<DeviceCapabilitiesLoading>(),
        isA<DeviceMediaSuccess>(),
      ],
    );
  });

  group('Audio Recording Tests', () {
    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'emits [DeviceAudioRecordSuccess] when recording starts and stops',
      build: () {
        when(
          () => mockPermissionService.checkPermission(Permission.microphone),
        ).thenAnswer((_) async => PermissionStatus.granted);
        when(
          () => mockAudioRecorderService.startRecording(),
        ).thenAnswer((_) async {});
        when(() => mockAudioRecorderService.stopRecording()).thenAnswer(
          (_) async => const MediaFileModel(
            name: 'audio.m4a',
            path: '/path/audio.m4a',
            sizeInBytes: 4096,
            fileType: 'm4a',
          ),
        );
        return cubit;
      },
      act: (cubit) async {
        await cubit.startAudioRecording();
        await cubit.stopAudioRecording();
      },
      expect: () => [
        isA<DeviceAudioRecordingInProgress>(),
        isA<DeviceAudioRecordSuccess>(),
      ],
    );

    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'prevents starting a second recording while one is in progress',
      build: () {
        when(
          () => mockPermissionService.checkPermission(Permission.microphone),
        ).thenAnswer((_) async => PermissionStatus.granted);
        when(
          () => mockAudioRecorderService.startRecording(),
        ).thenAnswer((_) async {});
        when(() => mockAudioRecorderService.stopRecording()).thenAnswer(
          (_) async => const MediaFileModel(
            name: 'audio.m4a',
            path: '/path/audio.m4a',
            sizeInBytes: 4096,
            fileType: 'm4a',
          ),
        );
        return cubit;
      },
      act: (cubit) async {
        await cubit.startAudioRecording();
        await cubit.startAudioRecording();
        await cubit.stopAudioRecording();
      },
      expect: () => [
        isA<DeviceAudioRecordingInProgress>(),
        isA<DeviceAudioRecordSuccess>(),
      ],
      verify: (_) {
        verify(() => mockAudioRecorderService.startRecording()).called(1);
      },
    );

    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'emits [DeviceOperationCancelled] when recording is cancelled',
      build: () {
        when(
          () => mockPermissionService.checkPermission(Permission.microphone),
        ).thenAnswer((_) async => PermissionStatus.granted);
        when(
          () => mockAudioRecorderService.startRecording(),
        ).thenAnswer((_) async {});
        when(
          () => mockAudioRecorderService.cancelRecording(),
        ).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) async {
        await cubit.startAudioRecording();
        await cubit.cancelAudioRecording();
      },
      expect: () => [
        isA<DeviceAudioRecordingInProgress>(),
        isA<DeviceOperationCancelled>(),
      ],
    );
  });

  group('Error Mapping Tests', () {
    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'maps unexpected camera error to error_occurred message key',
      build: () {
        when(
          () => mockPermissionService.checkPermission(Permission.camera),
        ).thenAnswer((_) async => PermissionStatus.granted);
        when(
          () => mockCameraGalleryService.capturePhoto(),
        ).thenThrow(Exception('camera failure'));
        return cubit;
      },
      act: (cubit) => cubit.openCamera(),
      expect: () => [
        isA<DeviceCapabilitiesLoading>(),
        isA<DeviceCapabilitiesError>().having(
          (e) => e.messageKey,
          'messageKey',
          'device_capabilities.error_occurred',
        ),
      ],
    );

    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'maps location timeout to location_timeout_msg message key',
      build: () {
        when(
          () => mockLocationService.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => mockPermissionService.checkPermission(Permission.location),
        ).thenAnswer((_) async => PermissionStatus.granted);
        when(
          () => mockLocationService.getCurrentLocation(),
        ).thenThrow(TimeoutException('timeout'));
        return cubit;
      },
      act: (cubit) => cubit.getCurrentLocation(),
      expect: () => [
        isA<DeviceCapabilitiesLoading>(),
        isA<DeviceCapabilitiesError>().having(
          (e) => e.messageKey,
          'messageKey',
          'device_capabilities.location_timeout_msg',
        ),
      ],
    );

    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'explains that a location must be retrieved before opening the map',
      build: () => cubit,
      act: (cubit) => cubit.openExternalMap(),
      expect: () => [
        isA<DeviceCapabilitiesError>().having(
          (e) => e.messageKey,
          'messageKey',
          'device_capabilities.no_location_yet_msg',
        ),
      ],
    );
  });

  group('Location Tests', () {
    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'emits [DeviceServiceDisabledState] when GPS service is disabled',
      build: () {
        when(
          () => mockLocationService.isLocationServiceEnabled(),
        ).thenAnswer((_) async => false);
        return cubit;
      },
      act: (cubit) => cubit.getCurrentLocation(),
      expect: () => [isA<DeviceServiceDisabledState>()],
    );

    blocTest<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      'emits [DeviceCapabilitiesLoading, DeviceLocationSuccess] when location retrieved',
      build: () {
        when(
          () => mockLocationService.isLocationServiceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => mockPermissionService.checkPermission(Permission.location),
        ).thenAnswer((_) async => PermissionStatus.granted);
        when(() => mockLocationService.getCurrentLocation()).thenAnswer(
          (_) async => LocationDataModel(
            latitude: 30.0,
            longitude: 31.0,
            accuracy: 5.0,
            retrievalTime: DateTime.now(),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.getCurrentLocation(),
      expect: () => [
        isA<DeviceCapabilitiesLoading>(),
        isA<DeviceLocationSuccess>(),
      ],
    );
  });
}
