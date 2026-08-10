import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<String?> saveImagePermanently(String? temporaryPath) async {
    if (temporaryPath == null || temporaryPath.isEmpty) return null;

    final file = File(temporaryPath);
    if (!await file.exists()) return null;

    final appDocDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(temporaryPath);
    final savedImage = await file.copy('${appDocDir.path}/$fileName');

    return savedImage.path;
  }

  static Future<void> deleteFile(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return;

    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<bool> isFileAvailable(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return false;
    return await File(filePath).exists();
  }
}
