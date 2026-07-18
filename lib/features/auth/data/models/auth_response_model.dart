class AuthResponseModel {
  final bool? mfaRequired;
  final List<String>? mfaMethods;
  final String? mfaToken;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? email;
  final String? role;

  AuthResponseModel({
    this.mfaRequired,
    this.mfaMethods,
    this.mfaToken,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.email,
    this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    List<String>? methods;
    if (json['methods'] is List) {
      methods = (json['methods'] as List).map((e) => e.toString()).toList();
    }

    return AuthResponseModel(
      mfaRequired:
          json['mfa_required'] == true || json['mfa']['verified'] == true,
      mfaMethods: methods,
      mfaToken: json['mfa_token']?.toString(),
      accessToken: json['access_token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      expiresIn: int.tryParse(json['expires_in']?.toString() ?? ''),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
    );
  }
}
