import 'package:spora_app/core/network/api_helper.dart';
import 'package:spora_app/core/network/api_response.dart';

class ChangePasswordRepo {
  final APIHelper apiHelper = APIHelper();

  ChangePasswordRepo();

  Future<ApiResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required String code,
  }) async {
    return await apiHelper.patchRequest(
      isProtected: true,
      endPoint: 'core/me/password',
      code: code,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      },
    );
  }
}
