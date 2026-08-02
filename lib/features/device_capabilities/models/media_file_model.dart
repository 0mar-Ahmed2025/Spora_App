class MediaFileModel {
  final String name;
  final String path;
  final int sizeInBytes;
  final String fileType;

  const MediaFileModel({
    required this.name,
    required this.path,
    required this.sizeInBytes,
    required this.fileType,
  });

  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}