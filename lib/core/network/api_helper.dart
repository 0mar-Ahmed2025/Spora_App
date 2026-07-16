// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:spora_app/core/cache/cache_helper.dart';
import 'package:spora_app/core/network/api_response.dart';
import 'package:spora_app/core/network/end_points.dart';

class _CacheHelperImpl extends CacheHelper {}

class APIHelper {
  static final Dio _dio = Dio(BaseOptions(baseUrl: EndPoints.baseUrl));
  static final _cacheHelper = _CacheHelperImpl();

  static Future init() async {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print("--- Headers : ${options.headers.toString()}");
          print("--- endpoint : ${options.path.toString()}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("--- Response : ${response.data.toString()}");
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          print("===== ON ERROR =====");
          print(error.response?.statusCode);
          print(error.response?.data);
          print(error.requestOptions.path);
          print("--- Error : ${error.response?.data.toString()}");

          try {
            if (error.response?.data != null &&
                error.response?.data is Map<String, dynamic>) {
              var errorResponse = error.response!.data as Map<String, dynamic>;
              var reason = errorResponse['reason']?.toString() ?? '';
              var messageEn = errorResponse['message_en']?.toString() ?? '';

              if (reason == 'UNAUTHENTICATED' ||
                  messageEn.contains('Invalid token') ||
                  reason == 'MFA_TOKEN_INVALID') {
                final refreshToken = await _cacheHelper.getRefreshToken();

                var result = await _dio.post(
                  EndPoints.refreshToken,
                  data: {'refresh_token': refreshToken},
                );

                var accessData = result.data as Map<String, dynamic>;
                var tokenData = accessData['data'] as Map<String, dynamic>;

                await _cacheHelper.saveTokens(
                  tokenData['access_token'],
                  refreshToken: tokenData['refresh_token'],
                );

                final options = error.requestOptions;
                if (options.data is FormData) {
                  final oldFormData = options.data as FormData;
                  final Map<String, dynamic> formMap = {};
                  for (var entry in oldFormData.fields) {
                    formMap[entry.key] = entry.value;
                  }
                  for (var file in oldFormData.files) {
                    formMap[file.key] = file.value;
                  }
                  options.data = FormData.fromMap(formMap);
                }

                final newToken = await _cacheHelper.getAccessToken();
                options.headers['Authorization'] = 'Bearer ${newToken ?? ''}';

                final response = await _dio.fetch(options);
                return handler.resolve(response);
              }
            }
          } catch (e) {
            print("--- Exception inside Interceptor: ${e.toString()}");
          }

          return handler.next(error);
        },
      ),
    );
  }

  static Future<String?> _getToken(bool sendRefreshToken) async {
    return sendRefreshToken
        ? await _cacheHelper.getRefreshToken()
        : await _cacheHelper.getAccessToken();
  }

  Future<ApiResponse> getRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
    bool isProtected = false,
    bool sendRefreshToken = false,
  }) async {
    String? token;
    if (isProtected) {
      token = await _getToken(sendRefreshToken);
    }
    try {
      var response = await _dio.get(
        endPoint,
        queryParameters: queryParameters,
        data: isFormData ? FormData.fromMap(data ?? {}) : data,
        options: Options(
          headers: {if (isProtected) 'Authorization': 'Bearer $token'},
        ),
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.fromError(e);
    }
  }

  Future<ApiResponse> postRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isFormData = false,
    bool isProtected = false,
    bool sendRefreshToken = false,
  }) async {
    String? token;
    if (isProtected) {
      token = await _getToken(sendRefreshToken);
    }
    try {
      var response = await _dio.post(
        endPoint,
        data: isFormData ? FormData.fromMap(data ?? {}) : data,
        options: Options(
          headers: {if (isProtected) 'Authorization': 'Bearer $token'},
        ),
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.fromError(e);
    }
  }

  Future<ApiResponse> putRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = true,
    bool isProtected = false,
    bool sendRefreshToken = false,
  }) async {
    String? token;
    if (isProtected) {
      token = await _getToken(sendRefreshToken);
    }
    try {
      var response = await _dio.put(
        endPoint,
        queryParameters: queryParameters,
        data: isFormData ? FormData.fromMap(data ?? {}) : data,
        options: Options(
          headers: {if (isProtected) 'Authorization': 'Bearer $token'},
        ),
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.fromError(e);
    }
  }

  Future<ApiResponse> deleteRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
    bool isProtected = true,
    bool sendRefreshToken = false,
  }) async {
    String? token;
    if (isProtected) {
      token = await _getToken(sendRefreshToken);
    }
    try {
      var response = await _dio.delete(
        endPoint,
        queryParameters: queryParameters,
        data: isFormData ? FormData.fromMap(data ?? {}) : data,
        options: Options(
          headers: {if (isProtected) 'Authorization': 'Bearer $token'},
        ),
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.fromError(e);
    }
  }

  Future<ApiResponse> patchRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
    bool isProtected = false,
    bool sendRefreshToken = false,
    String? code,
  }) async {
    String? token;

    if (isProtected) {
      token = await _getToken(sendRefreshToken);
    }
    try {
      var response = await _dio.patch(
        endPoint,
        queryParameters: queryParameters,
        data: isFormData && data != null ? FormData.fromMap(data) : data,
        options: Options(
          headers: {
            if (isProtected) 'Authorization': 'Bearer $token',
            'X-MFA-Code': code,
          },
        ),
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.fromError(e);
    }
  }
}
