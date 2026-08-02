import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/generated/locale_keys.g.dart';
import '../cubit/device_capabilities_cubit.dart';
import '../cubit/device_capabilities_state.dart';

class AudioRecorderSheet extends StatelessWidget {
  const AudioRecorderSheet({super.key});

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DeviceCapabilitiesCubit>();

    return BlocBuilder<DeviceCapabilitiesCubit, DeviceCapabilitiesState>(
      builder: (context, state) {
        final isRecording = state is DeviceAudioRecordingInProgress;
        final seconds = isRecording ? state.durationInSeconds : 0;

        return SafeArea(
          child: Padding(
            padding: REdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.device_capabilities_record_audio.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),

                Container(
                  padding: REdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.mic,
                    size: 64.sp,
                    color: isRecording ? Colors.redAccent : Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  isRecording ? _formatDuration(seconds) : '00:00',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),

                if (!isRecording) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: REdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      cubit.startAudioRecording();
                    },
                    icon: const Icon(
                      Icons.fiber_manual_record,
                      color: Colors.white,
                    ),
                    label: Text(
                      LocaleKeys.device_capabilities_start_recording.tr(),
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44.h,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              textStyle: TextStyle(fontSize: 11.sp),
                            ),
                            onPressed: () {
                              cubit.cancelAudioRecording();
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.cancel, size: 18.sp),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                LocaleKeys
                                    .device_capabilities_cancel_recording
                                    .tr(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: SizedBox(
                          height: 44.h,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              textStyle: TextStyle(fontSize: 11.sp),
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              cubit.stopAudioRecording();
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.stop, size: 18.sp),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                LocaleKeys
                                    .device_capabilities_stop_recording
                                    .tr(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
