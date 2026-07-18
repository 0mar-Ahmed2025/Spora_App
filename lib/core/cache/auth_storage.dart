abstract class AuthStorage {
  Future<void> saveTokens(
    String accessToken, {
    required String refreshToken,
  });

  Future<void> saveMfaToken(String mfaToken);

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<String?> getMfaToken();

  Future<void> clearMfaToken();

  Future<void> clearAuthData();
}
