// ignore_for_file: empty_catches
import 'dart:developer';

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
        // sendRefreshToken: true,
        endPoint: EndPoints.getProfileInfo,
      );
      log(response.data.toString());
      var userModel = UserData.fromJson(response.data as Map<String, dynamic>);
      if (response.status) {
        return right(userModel);
      } else {
        return left(response.message);
      }
    } catch (e) {
      return left(ApiResponse.fromError(e).message);
    }
  }


}
