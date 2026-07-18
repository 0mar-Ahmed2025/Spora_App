import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spora_app/features/profile/cubit/profile_image/profile_image_state.dart';
import 'package:spora_app/features/profile/data/repo/profile_image_repo.dart';

class ProfileImageCubit extends Cubit<ProfileImageState> {
  ProfileImageCubit() : super(ProfileImageInitial());

  static ProfileImageCubit get(context) => BlocProvider.of(context);

  final ProfileImageRepo repository = ProfileImageRepo();
  XFile? imagePath;

  void selectImage(XFile file) {
    imagePath = file;
    emit(ProfileImageSelected());
  }

  Future<void> uploadSelectedImage() async {
    if (imagePath == null) {
      emit(ProfileImageFailure('Please select an image first'));
      return;
    }

    emit(ProfileImageLoading());

    try {
      final uploadInfo = await repository.getUploadUrl();

      await repository.uploadImage(
        fileKey: uploadInfo.fileKey,
        image: File(imagePath!.path),
      );

      await repository.commitImage(fileKey: uploadInfo.fileKey);

      imagePath = null;
      emit(ProfileImageSuccess());
    } catch (e) {
      emit(ProfileImageFailure(e.toString()));
    }
  }

  Future<void> deleteProfileImage() async {
    emit(ProfileImageLoading());

    try {
      await repository.deleteImage();
      imagePath = null;
      emit(ProfileImageSuccess());
    } catch (e) {
      emit(ProfileImageFailure(e.toString()));
    }
  }
}
