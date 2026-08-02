import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleKeys.device_capabilities_record_audio.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.mic,
                  size: 64,
                  color: isRecording ? Colors.redAccent : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                isRecording ? _formatDuration(seconds) : '00:00',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              if (!isRecording) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
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
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                        onPressed: () {
                          cubit.cancelAudioRecording();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.cancel),
                        label: Text(
                          LocaleKeys.device_capabilities_cancel_recording.tr(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 11),
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          cubit.stopAudioRecording();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.stop),
                        label: Text(
                          LocaleKeys.device_capabilities_stop_recording.tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
