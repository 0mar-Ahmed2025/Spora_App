import 'package:dartz/dartz.dart';
import 'package:spora_app/core/network/api_helper.dart';
import 'package:spora_app/core/network/api_response.dart';
import 'package:spora_app/core/network/end_points.dart';

class AuthRepository {
  final APIHelper _apiHelper = APIHelper();

  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    return await _apiHelper.postRequest(
      endPoint: EndPoints.login,
      data: {'email': email, 'password': password},
    );
  }

  Future<ApiResponse> verifyMfa({
    required String code,
    String? mfaToken,
  }) async {
    return await _apiHelper.postRequest(
      endPoint: "auth/mfa/verify",
      data: {
        'code': code,
        'context': 'login',
        if (mfaToken != null) 'mfa_token': mfaToken,
      },
    );
  }

  Future<ApiResponse> logout({required String refreshToken}) async {
    return await _apiHelper.postRequest(
      endPoint: EndPoints.logout,
      data: {'refresh_token': refreshToken},
    );
  }

  Future<Either<String, String>> register({
    required String name,
    required String email,
    required String password,
    String? imagePath,
  }) async {
    try {
      var response = await _apiHelper.postRequest(
        endPoint: EndPoints.register,
        data: {'username': name, 'password': password, 'email': email},
      );

      if (response.status) {
        // serialization
        return right(response.message);
      } else {
        return left(response.message);
      }
    } catch (e) {
      return left(ApiResponse.fromError(e).message);
    }
  }


}
