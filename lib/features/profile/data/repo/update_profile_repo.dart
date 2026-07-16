import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spora_app/core/network/api_helper.dart';
import 'package:spora_app/core/network/api_response.dart';

class UpdateProfileRepo {
  APIHelper apiHelper = APIHelper();

  Future<Either<String, String>> updateProfile({
    required String firstName,
    required String lastName,
    required String displayName,
    required String timeZone,
    required String phoneNumber,

    XFile? image,
  }) async {
    try {
      var response = await apiHelper.putRequest(
        endPoint: 'core/users/me',
        isProtected: true,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'display_name': displayName,
          'mobile': phoneNumber,
        },
      );
      if (response.status) {
        return right(response.message);
      } else {
        return left(response.message);
      }
    } catch (e) {
      return left(ApiResponse.fromError(e).message);
    }
  }

  Future<Either<String, String>> deleteCompany({
    required String companyId,
  }) async {
    try {
      var response = await apiHelper.deleteRequest(
        endPoint: '',
        isProtected: true,
      );
      if (response.status) {
        return right(response.message);
      } else {
        return left(response.message);
      }
    } catch (e) {
      return left(ApiResponse.fromError(e).message);
    }
  }
}
