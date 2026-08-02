import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/features/device_capabilities/services/audio_recorder_service.dart';
import 'package:spora_app/features/device_capabilities/services/camera_gallery_service.dart';
import 'package:spora_app/features/device_capabilities/services/file_picker_service.dart';
import 'package:spora_app/features/device_capabilities/services/location_service.dart';
import 'package:spora_app/features/device_capabilities/services/map_launcher_service.dart';
import 'package:spora_app/features/device_capabilities/services/permission_service.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

import '../cubit/device_capabilities_cubit.dart';
import '../cubit/device_capabilities_state.dart';
import '../views/audio_recorder_sheet.dart';
import '../views/location_result_sheet.dart';
import '../views/media_preview_sheet.dart';
import 'device_capability_tile.dart';

class DeviceCapabilitiesSection extends StatelessWidget {
  const DeviceCapabilitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceCapabilitiesCubit(
        permissionService: PermissionServiceImpl(),
        cameraGalleryService: CameraGalleryServiceImpl(),
        locationService: LocationServiceImpl(),
        mapLauncherService: MapLauncherServiceImpl(),
        filePickerService: FilePickerServiceImpl(),
        audioRecorderService: AudioRecorderServiceImpl(),
      ),
      child: BlocConsumer<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
        listener: (context, state) {
          if (state is DeviceMediaSuccess) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => MediaPreviewSheet(mediaFile: state.mediaFile),
            );
          } else if (state is DeviceAudioRecordSuccess) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => MediaPreviewSheet(mediaFile: state.audioFile),
            );
          } else if (state is DeviceLocationSuccess) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) =>
                  LocationResultSheet(locationData: state.locationData),
            );
          } else if (state is DevicePermissionPermanentlyDenied) {
            _showPermissionDialog(context);
          } else if (state is DevicePermissionDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LocaleKeys.device_capabilities_permission_denied_msg.tr(),
                ),
              ),
            );
          } else if (state is DeviceServiceDisabledState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LocaleKeys.device_capabilities_location_disabled_msg.tr(),
                ),
              ),
            );
          } else if (state is DeviceCapabilitiesError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.messageKey.tr())));
          }
        },
        builder: (context, state) {
          final cubit = context.read<DeviceCapabilitiesCubit>();
          final isLoading = state is DeviceCapabilitiesLoading;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                padding: const EdgeInsets.all(12.0),
                childAspectRatio: 1.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  DeviceCapabilityTile(
                    title: LocaleKeys.device_capabilities_open_camera.tr(),
                    icon: Icons.camera_alt,
                    isLoading: isLoading,
                    onTap: cubit.openCamera,
                  ),
                  DeviceCapabilityTile(
                    title: LocaleKeys.device_capabilities_select_gallery.tr(),
                    icon: Icons.photo_library,
                    isLoading: isLoading,
                    onTap: cubit.selectFromGallery,
                  ),
                  DeviceCapabilityTile(
                    title: LocaleKeys.device_capabilities_get_location.tr(),
                    icon: Icons.my_location,
                    isLoading: isLoading,
                    onTap: cubit.getCurrentLocation,
                  ),
                  DeviceCapabilityTile(
                    title: LocaleKeys.device_capabilities_open_external_map
                        .tr(),
                    icon: Icons.map,
                    isLoading: isLoading,
                    onTap: cubit.openExternalMap,
                  ),
                  DeviceCapabilityTile(
                    title: LocaleKeys.device_capabilities_pick_file.tr(),
                    icon: Icons.attach_file,
                    isLoading: isLoading,
                    onTap: cubit.pickFile,
                  ),
                  DeviceCapabilityTile(
                    title: LocaleKeys.device_capabilities_record_audio.tr(),
                    icon: Icons.mic,
                    isLoading: isLoading,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isDismissible: false,
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: const AudioRecorderSheet(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKeys.device_capabilities_permission_required.tr()),
        content: Text(
          LocaleKeys.device_capabilities_permission_permanently_denied_msg.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(LocaleKeys.device_capabilities_cancel.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DeviceCapabilitiesCubit>().openAppSettings();
            },
            child: Text(LocaleKeys.device_capabilities_open_settings.tr()),
          ),
        ],
      ),
    );
  }
}
