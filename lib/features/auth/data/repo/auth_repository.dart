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

      endPoint: EndPoints.mfaVerify,

      data: {

        'code': code,

        'context': 'login',

        if (mfaToken != null && mfaToken.isNotEmpty) 'mfa_token': mfaToken,

      },

    );

  }



  Future<ApiResponse> resendMfa({required String mfaToken}) async {

    return await _apiHelper.postRequest(

      endPoint: EndPoints.mfaResend,

      data: {'mfa_token': mfaToken},

    );

  }



  Future<ApiResponse> forgotPassword({required String email}) async {

    return await _apiHelper.postRequest(

      endPoint: EndPoints.forgotPassword,

      data: {'email': email},

    );

  }



  Future<ApiResponse> logout({required String refreshToken}) async {

    return await _apiHelper.postRequest(

      endPoint: EndPoints.logout,

      data: {'refresh_token': refreshToken},

    );

  }

}


