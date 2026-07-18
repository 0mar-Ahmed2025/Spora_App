class UploadUrlResponse {
  final String uploadUrl;
  final String fileKey;
  final String expiresAt;

  UploadUrlResponse({
    required this.uploadUrl,
    required this.fileKey,
    required this.expiresAt,
  });

  factory UploadUrlResponse.fromJson(Map<String, dynamic> json) {
    return UploadUrlResponse(
      uploadUrl: json['upload_url']?.toString() ?? '',
      fileKey: json['file_key']?.toString() ?? '',
      expiresAt: json['expires_at']?.toString() ?? '',
    );
  }
}
