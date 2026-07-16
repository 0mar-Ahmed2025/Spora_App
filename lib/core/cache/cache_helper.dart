// ignore_for_file: strict_top_level_inference

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spora_app/core/cache/cache_keys.dart';

class CacheHelper {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  saveTokens(accessToken, {required String refreshToken}) async {
    await _storage.write(key: CacheKeys.accessTokenKey, value: accessToken);
    await _storage.write(key: CacheKeys.refreshTokenKey, value: refreshToken);
  }

  saveMfaToken(String mfaToken) async {
    await _storage.write(key: CacheKeys.mfaTokenKey, value: mfaToken);
  }

  saveTokenCode(String code) async {
    await _storage.write(key: CacheKeys.tokenCode, value: code);
  }

  getCode() async {
    return await _storage.read(key: CacheKeys.tokenCode);
  }

  getAccessToken() async {
    return await _storage.read(key: CacheKeys.accessTokenKey);
  }

  getRefreshToken() async {
    return await _storage.read(key: CacheKeys.refreshTokenKey);
  }

  getMfaToken() async {
    return await _storage.read(key: CacheKeys.mfaTokenKey);
  }

  clearAuthData() async {
    await _storage.delete(key: CacheKeys.accessTokenKey);
    await _storage.delete(key: CacheKeys.refreshTokenKey);
    await _storage.delete(key: CacheKeys.mfaTokenKey);
  }
}
