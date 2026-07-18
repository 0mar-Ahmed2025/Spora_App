import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiResponse {
  final bool status;
  final int statusCode;
  final dynamic data;
  final String message;

  ApiResponse({
    required this.status,
    required this.statusCode,
    this.data,
    required this.message,
  });

  factory ApiResponse.fromResponse(Response response) {
    bool isSuccess = response.data is Map<String, dynamic>
        ? (response.data['ok'] ?? false)
        : (response.statusCode == 200 || response.statusCode == 201);

    String msg = 'An error occurred.';
    dynamic payloadData;

    if (response.data is Map<String, dynamic>) {
      msg =
          response.data['message_en'] ??
          response.data['reason'] ??
          (isSuccess ? 'Success' : 'An error occurred.');
      payloadData = response.data['data'];
    } else {
      msg = isSuccess ? 'Success' : 'An error occurred.';
      payloadData = response.data;
    }

    return ApiResponse(
      status: isSuccess,
      statusCode: response.statusCode ?? 500,
      data: payloadData,
      message: msg,
    );
  }

  factory ApiResponse.fromError(dynamic error) {
    if (kDebugMode && error is DioException) {
      print(
        'Api error: ${error.type.name} '
        '${error.response?.statusCode ?? ''} '
        '${error.requestOptions.path}',
      );
    } else if (kDebugMode) {
      print('Api error: ${error.runtimeType}');
    }

    if (error is DioException) {
      return ApiResponse(
        status: false,
        data: error.response?.data,
        statusCode: error.response != null
            ? (error.response!.statusCode ?? 500)
            : 500,
        message: _handleDioError(error),
      );
    } else {
      return ApiResponse(
        status: false,
        statusCode: 500,
       message: 'App Error: An unexpected error occurred.',
      );
    }
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout, please try again.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout, please check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout, please try again later.';
      case DioExceptionType.badResponse:
        return _handleServerError(error.response);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Unknown error occurred.';
    }
  }

  static String _handleServerError(Response? response) {
    if (response == null) return 'No response from server.';
    if (response.data is Map<String, dynamic>) {
      if (response.data['message_en'] != null) {
        return response.data['message_en'];
      }
      if (response.data['reason'] != null) {
        return response.data['reason'];
      }
      return 'Server error without message.';
    }
    return 'Server error: ${response.statusMessage}';
  }
}
