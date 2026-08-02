import 'package:image_picker/image_picker.dart';
import 'package:spora_app/features/device_capabilities/models/media_file_model.dart';

abstract class CameraGalleryService {
  Future<MediaFileModel?> capturePhoto();
  Future<MediaFileModel?> pickImageFromGallery();
}

class CameraGalleryServiceImpl implements CameraGalleryService {
  final ImagePicker _picker;

  CameraGalleryServiceImpl({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  @override
  Future<MediaFileModel?> capturePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    return _mapXFileToMediaModel(image);
  }

  @override
  Future<MediaFileModel?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return _mapXFileToMediaModel(image);
  }

  Future<MediaFileModel> _mapXFileToMediaModel(XFile file) async {
    final fileBytes = await file.length();
    final extension = file.path.split('.').last;
    return MediaFileModel(
      name: file.name,
      path: file.path,
      sizeInBytes: fileBytes,
      fileType: extension,
    );
  }
}
