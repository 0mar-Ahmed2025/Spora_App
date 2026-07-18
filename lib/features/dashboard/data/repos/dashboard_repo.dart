import 'package:dartz/dartz.dart';
import 'package:spora_app/core/network/api_helper.dart';
import 'package:spora_app/core/network/api_response.dart';
import 'package:spora_app/core/network/end_points.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';

class DashboardRepo {
  APIHelper apiHelper = APIHelper();

  Future<Either<String, UserData>> getProfile() async {
    try {
      var response = await apiHelper.getRequest(
        isProtected: true,
        endPoint: EndPoints.getProfileInfo,
      );

      if (response.status && response.data is Map) {
        var userModel = UserData.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        return right(userModel);
      }

      if (!response.status) {
        return left(response.message);
      }

      return left('Invalid data format received from server.');
    } catch (e) {
      return left(ApiResponse.fromError(e).message);
    }
  }
}
