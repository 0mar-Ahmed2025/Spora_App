import 'package:file_picker/file_picker.dart';
import '../models/media_file_model.dart';

abstract class FilePickerService {
  Future<MediaFileModel?> pickSingleFile();
}

class FilePickerServiceImpl implements FilePickerService {
  final FilePicker _filePicker;

  FilePickerServiceImpl({FilePicker? filePicker})
    : _filePicker = filePicker ?? FilePicker.platform;

  @override
  Future<MediaFileModel?> pickSingleFile() async {
    final FilePickerResult? result = await _filePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final PlatformFile file = result.files.first;
    if (file.path == null) return null;

    return MediaFileModel(
      name: file.name,
      path: file.path!,
      sizeInBytes: file.size,
      fileType: file.extension ?? 'unknown',
    );
  }
}
