class EndPoints {
  static const String login = 'auth/login';
  static const String refreshToken = 'auth/refresh';
  static const String logout = 'auth/logout';
  static const String profile = 'core/users/me';
  static const String forgotPassword = 'auth/password/forgot';
  static const String mfaResend = 'auth/mfa/resend';
  static const String getProfileInfo = 'core/users/me';
  static const String uploadUrl = 'core/users/me/profile-image/upload-url';
  static const String upload = 'core/users/me/profile-image/upload';
  static const String commit = 'core/users/me/profile-image/commit';
  static const String deleteImage = 'core/users/me/profile-image';
  static const String mfaVerify = 'auth/mfa/verify';
  static const String mfaSetup = 'auth/mfa/setup';
  static const String mfaDisable = 'auth/mfa/disable';
}
