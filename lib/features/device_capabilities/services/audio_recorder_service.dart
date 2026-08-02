import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:spora_app/features/device_capabilities/models/media_file_model.dart';

abstract class AudioRecorderService {
  Future<void> startRecording();
  Future<MediaFileModel?> stopRecording();
  Future<void> cancelRecording();
  Future<bool> isRecording();
  Stream<RecordState> get onStateChanged;
  Future<void> dispose();
}

class AudioRecorderServiceImpl implements AudioRecorderService {
  final AudioRecorder _audioRecorder;
  String? _currentPath;

  AudioRecorderServiceImpl({AudioRecorder? audioRecorder})
    : _audioRecorder = audioRecorder ?? AudioRecorder();

  @override
  Future<void> startRecording() async {
    final Directory tempDir = await getTemporaryDirectory();
    final String path =
        '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _currentPath = path;

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
  }

  @override
  Future<MediaFileModel?> stopRecording() async {
    final String? path = await _audioRecorder.stop();
    if (path == null) return null;

    final File file = File(path);
    if (!await file.exists()) return null;

    final int size = await file.length();
    final String name = path.split('/').last;

    return MediaFileModel(
      name: name,
      path: path,
      sizeInBytes: size,
      fileType: 'm4a',
    );
  }

  @override
  Future<void> cancelRecording() async {
    await _audioRecorder.stop();
    if (_currentPath != null) {
      final File file = File(_currentPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _currentPath = null;
    }
  }

  @override
  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  @override
  Stream<RecordState> get onStateChanged => _audioRecorder.onStateChanged();

  @override
  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}
