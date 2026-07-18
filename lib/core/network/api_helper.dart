import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spora_app/core/cache/cache_helper.dart';
import 'package:spora_app/core/network/api_response.dart';
import 'package:spora_app/core/network/end_points.dart';
import 'package:spora_app/core/routing/app_router.dart';
import 'package:spora_app/core/routing/app_routes.dart';

class _CacheHelperImpl extends CacheHelper {}

class APIHelper {
  static late final Dio _dio;
  static late final Dio _refreshDio;
  static final _cacheHelper = _CacheHelperImpl();
  static bool _isRefreshing = false;
  static final List<MapEntry<RequestOptions, ErrorInterceptorHandler>>
  _queuedRequests = [];

  static Future<void> init() async {
    var baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isNotEmpty && !baseUrl.endsWith('/')) {
      baseUrl = '$baseUrl/';
    }

    _dio = Dio(BaseOptions(baseUrl: baseUrl));
    _refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print("Request: ${options.method} ${options.path}");
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              "Response: ${response.statusCode} ${response.requestOptions.path}",
            );
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (kDebugMode) {
            print(
              "Error: ${error.response?.statusCode} ${error.requestOptions.path}",
            );
          }

          if (error.response?.statusCode == 401) {
            try {
              if (error.response?.data is Map) {
                var errorResponse = Map<String, dynamic>.from(
                  error.response!.data as Map,
                );
                var reason = errorResponse['reason']?.toString() ?? '';
                var messageEn = errorResponse['message_en']?.toString() ?? '';

                if (reason == 'UNAUTHENTICATED' ||
                    messageEn.contains('Invalid token')) {
                  final options = error.requestOptions;

                  if (options.extra['retried'] == true) {
                    await _cacheHelper.clearAuthData();
                    AppRouter.router.go(AppRoutes.login);
                    return handler.next(error);
                  }

                  if (_isRefreshing) {
                    _queuedRequests.add(MapEntry(options, handler));
                    return;
                  }

                  _isRefreshing = true;
                  final refreshToken = await _cacheHelper.getRefreshToken();

                  if (refreshToken == null || refreshToken.isEmpty) {
                    _isRefreshing = false;
                    await _cacheHelper.clearAuthData();
                    AppRouter.router.go(AppRoutes.login);
                    return handler.next(error);
                  }

                  try {
                    var result = await _refreshDio.post(
                      EndPoints.refreshToken,
                      data: {'refresh_token': refreshToken},
                    );

                    if (result.data is! Map) {
                      throw DioException(requestOptions: options);
                    }

                    var accessData = Map<String, dynamic>.from(
                      result.data as Map,
                    );
                    final dataField = accessData['data'];
                    if (dataField is! Map) {
                      throw DioException(requestOptions: options);
                    }

                    var tokenData = Map<String, dynamic>.from(dataField);
                    final newAccessToken =
                        tokenData['access_token']?.toString().trim() ?? '';
                    final newRefreshToken =
                        tokenData['refresh_token']?.toString().trim() ?? '';

                    if (newAccessToken.isEmpty) {
                      throw DioException(requestOptions: options);
                    }

                    await _cacheHelper.saveTokens(
                      newAccessToken,
                      refreshToken: newRefreshToken,
                    );

                    options.headers['Authorization'] = 'Bearer $newAccessToken';
                    options.extra['retried'] = true;
                    if (options.data is FormData) {
                      options.data = (options.data as FormData).clone();
                    }

                    for (var queued in _queuedRequests) {
                      try {
                        queued.key.headers['Authorization'] =
                            'Bearer $newAccessToken';
                        queued.key.extra['retried'] = true;
                        if (queued.key.data is FormData) {
                          queued.key.data = (queued.key.data as FormData)
                              .clone();
                        }
                        final queuedResponse = await _dio.fetch(queued.key);
                        queued.value.resolve(queuedResponse);
                      } catch (e) {
                        queued.value.reject(
                          e is DioException
                              ? e
                              : DioException(
                                  requestOptions: queued.key,
                                  error: e,
                                ),
                        );
                      }
                    }
                    _queuedRequests.clear();
                    _isRefreshing = false;

                    final response = await _dio.fetch(options);
                    return handler.resolve(response);
                  } catch (refreshError) {
                    _isRefreshing = false;
                    for (var queued in _queuedRequests) {
                      queued.value.reject(
                        refreshError is DioException
                            ? refreshError
                            : DioException(
                                requestOptions: queued.key,
                                error: refreshError,
                              ),
                      );
                    }
                    _queuedRequests.clear();
                    await _cacheHelper.clearAuthData();
                    AppRouter.router.go(AppRoutes.login);
                    return handler.next(error);
                  }
                }
              }
            } catch (e) {
              _isRefreshing = false;
              for (var queued in _queuedRequests) {
                queued.value.reject(error);
              }
              _queuedRequests.clear();
              if (kDebugMode) {
                print(
                  "Interceptor Exception: ${e.runtimeType} occurred during refresh.",
                );
              }
            }
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
        data: isFormData && data != null ? FormData.fromMap(data) : data,
        options: Options(
          headers: {
            if (isProtected && token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
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
        data: isFormData && data != null ? FormData.fromMap(data) : data,
        options: Options(
          headers: {
            if (isProtected && token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
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
    bool isFormData = false,
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
        data: isFormData && data != null ? FormData.fromMap(data) : data,
        options: Options(
          headers: {
            if (isProtected && token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
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
        data: isFormData && data != null ? FormData.fromMap(data) : data,
        options: Options(
          headers: {
            if (isProtected && token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
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
            if (isProtected && token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            if (code != null && code.isNotEmpty) 'X-MFA-Code': code,
          },
        ),
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse.fromError(e);
    }
  }
}
