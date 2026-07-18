import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:spora_app/core/cache/auth_storage.dart';

import 'package:spora_app/core/cache/cache_keys.dart';

class CacheHelper implements AuthStorage {
  final FlutterSecureStorage _storage;

  CacheHelper({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveTokens(
    String accessToken, {

    required String refreshToken,
  }) async {
    await _storage.write(key: CacheKeys.accessTokenKey, value: accessToken);

    await _storage.write(key: CacheKeys.refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> saveMfaToken(String mfaToken) async {
    await _storage.write(key: CacheKeys.mfaTokenKey, value: mfaToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: CacheKeys.accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: CacheKeys.refreshTokenKey);
  }

  @override
  Future<String?> getMfaToken() async {
    return await _storage.read(key: CacheKeys.mfaTokenKey);
  }

  @override
  Future<void> clearMfaToken() async {
    await _storage.delete(key: CacheKeys.mfaTokenKey);
  }

  @override
  Future<void> clearAuthData() async {
    await _storage.delete(key: CacheKeys.accessTokenKey);

    await _storage.delete(key: CacheKeys.refreshTokenKey);

    await _storage.delete(key: CacheKeys.mfaTokenKey);
  }
}
