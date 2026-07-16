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
    return AuthResponseModel(
      mfaRequired: json['mfa_required'] as bool?,
      mfaMethods: (json['methods'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      mfaToken: json['mfa_token'] as String?,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: json['expires_in'] as int?,
      email: json['email'] as String?,
      role: json['role'] as String?,
    );
  }
}
