import 'package:spora_app/core/network/api_helper.dart';
import 'package:spora_app/core/network/api_response.dart';
import 'package:spora_app/core/network/end_points.dart';
import 'package:spora_app/features/settings/data/model/mfa_setup_model.dart';

class MfaSettingsRepo {
  final APIHelper apiHelper = APIHelper();

  Future<ApiResponse> setupMfa() async {
    return await apiHelper.postRequest(
      endPoint: EndPoints.mfaSetup,
      isProtected: true,
      data: {
        'issuer': 'MAYA',
        'label': 'Mobile App',
      },
    );
  }

  Future<ApiResponse> verifySetup({required String code}) async {
    return await apiHelper.postRequest(
      endPoint: EndPoints.mfaVerify,
      isProtected: true,
      data: {
        'code': code,
        'context': 'setup',
      },
    );
  }

  Future<ApiResponse> disableMfa({
    required String password,
    required String code,
  }) async {
    return await apiHelper.postRequest(
      endPoint: EndPoints.mfaDisable,
      isProtected: true,
      data: {
        'password': password,
        'code': code,
      },
    );
  }

  MfaSetupModel? parseSetupData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return MfaSetupModel.fromJson(data);
    }
    if (data is Map) {
      return MfaSetupModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
}
