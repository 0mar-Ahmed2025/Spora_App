// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spora_app/features/profile/cubit/update_profile_state.dart';
import 'package:spora_app/features/profile/data/repo/update_profile_repo.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  UpdateProfileCubit() : super(UpdateProfileInitialState());

  static UpdateProfileCubit get(context) => BlocProvider.of(context);

  UpdateProfileRepo repo = UpdateProfileRepo();

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var displayNameController = TextEditingController();
  var phoneNumber = TextEditingController();

  var timeZoneController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  XFile? imagePath;

  void setImagePath(String path) {
    imagePath = XFile(path);
    emit(UpdateProfileImagePicked());
  }

  updateProfile() async {
    if (formKey.currentState?.validate() == false) return;

    emit(UpdateCompanyLoadingState());

    var result = await repo.updateProfile(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      displayName: displayNameController.text,
      timeZone: timeZoneController.text,
      phoneNumber: phoneNumber.text,
    );

    result.fold(
      (errorMsg) => emit(UpdateProfileErrorState(errorMsg)),
      (successMsg) => emit(UpdateProfileSuccessState(successMsg)),
    );
  }

  @override
  Future<void> close() {
    firstNameController.dispose();
    lastNameController.dispose();
    displayNameController.dispose();
    timeZoneController.dispose();
    phoneNumber.dispose();

    return super.close();
  }
}
