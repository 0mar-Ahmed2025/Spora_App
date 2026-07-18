import 'dart:io';

import 'package:dio/dio.dart';
import 'package:spora_app/core/network/api_helper.dart';
import 'package:spora_app/core/network/api_response.dart';
import 'package:spora_app/core/network/end_points.dart';
import 'package:spora_app/features/profile/data/model/upload_image_url_response_model.dart';

class ProfileImageRepo {
  final APIHelper apiHelper = APIHelper();

  Future<UploadUrlResponse> getUploadUrl() async {
    final ApiResponse response = await apiHelper.postRequest(
      endPoint: EndPoints.uploadUrl,
      isProtected: true,
    );

    if (!response.status || response.data == null) {
      throw Exception(response.message);
    }

    return UploadUrlResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> uploadImage({
    required String fileKey,
    required File image,
  }) async {
    final String fileName = image.path.replaceAll('\\', '/').split('/').last;

    final ApiResponse response = await apiHelper.postRequest(
      endPoint: EndPoints.upload,
      isProtected: true,
      isFormData: true,
      data: {
        'file_key': fileKey,
        'file': await MultipartFile.fromFile(image.path, filename: fileName),
      },
    );

    if (!response.status) {
      throw Exception(response.message);
    }
  }

  Future<void> commitImage({required String fileKey}) async {
    final ApiResponse response = await apiHelper.postRequest(
      endPoint: EndPoints.commit,
      isProtected: true,
      data: {'file_key': fileKey},
    );

    if (!response.status) {
      throw Exception(response.message);
    }
  }

  Future<void> deleteImage() async {
    final ApiResponse response = await apiHelper.deleteRequest(
      endPoint: EndPoints.deleteImage,
      isProtected: true,
    );

    if (!response.status) {
      throw Exception(response.message);
    }
  }
}
