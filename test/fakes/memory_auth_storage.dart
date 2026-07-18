import 'package:spora_app/core/cache/auth_storage.dart';
import 'package:spora_app/core/cache/cache_keys.dart';

class MemoryAuthStorage implements AuthStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> clearAuthData() async {
    _store.remove(CacheKeys.accessTokenKey);
    _store.remove(CacheKeys.refreshTokenKey);
    _store.remove(CacheKeys.mfaTokenKey);
  }

  @override
  Future<void> clearMfaToken() async {
    _store.remove(CacheKeys.mfaTokenKey);
  }

  @override
  Future<String?> getAccessToken() async => _store[CacheKeys.accessTokenKey];

  @override
  Future<String?> getMfaToken() async => _store[CacheKeys.mfaTokenKey];

  @override
  Future<String?> getRefreshToken() async => _store[CacheKeys.refreshTokenKey];

  @override
  Future<void> saveMfaToken(String mfaToken) async {
    _store[CacheKeys.mfaTokenKey] = mfaToken;
  }

  @override
  Future<void> saveTokens(
    String accessToken, {
    required String refreshToken,
  }) async {
    _store[CacheKeys.accessTokenKey] = accessToken;
    _store[CacheKeys.refreshTokenKey] = refreshToken;
  }
}
