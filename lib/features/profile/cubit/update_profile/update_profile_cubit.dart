// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/features/profile/cubit/update_profile/update_profile_state.dart';
import 'package:spora_app/features/profile/data/repo/update_profile_repo.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  UpdateProfileCubit() : super(UpdateProfileInitialState());

  static UpdateProfileCubit get(context) => BlocProvider.of(context);

  UpdateProfileRepo repo = UpdateProfileRepo();

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var displayNameController = TextEditingController();
  var phoneNumber = TextEditingController();

  final formKey = GlobalKey<FormState>();
  updateProfile() async {
    if (formKey.currentState?.validate() == false) return;

    emit(UpdateProfileLoadingState());

    var result = await repo.updateProfile(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      displayName: displayNameController.text,
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
    phoneNumber.dispose();

    return super.close();
  }
}
