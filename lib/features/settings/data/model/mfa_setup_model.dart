class MfaSetupModel {
  final String type;
  final String issuer;
  final String label;
  final String secretBase32;
  final String otpauthUri;
  final String qrcodePngBase64;
  final String qrcodeDataUri;

  MfaSetupModel({
    required this.type,
    required this.issuer,
    required this.label,
    required this.secretBase32,
    required this.otpauthUri,
    required this.qrcodePngBase64,
    required this.qrcodeDataUri,
  });

  factory MfaSetupModel.fromJson(Map<String, dynamic> json) {
    return MfaSetupModel(
      type: json['type']?.toString() ?? 'totp',
      issuer: json['issuer']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      secretBase32: json['secret_base32']?.toString() ?? '',
      otpauthUri: json['otpauth_uri']?.toString() ?? '',
      qrcodePngBase64: json['qrcode_png_base64']?.toString() ?? '',
      qrcodeDataUri: json['qrcode_data_uri']?.toString() ?? '',
    );
  }

  String get qrBase64 {
    if (qrcodePngBase64.isNotEmpty) return qrcodePngBase64;
    if (qrcodeDataUri.contains(',')) {
      return qrcodeDataUri.split(',').last;
    }
    return qrcodeDataUri;
  }
}
