import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spora_app/core/helper/app_pop_up.dart';
import 'package:spora_app/core/helper/app_validator.dart';
import 'package:spora_app/core/shared/custom_button.dart';
import 'package:spora_app/core/shared/custom_textfield.dart';
import 'package:spora_app/core/shared/image_manager.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';
import 'package:spora_app/features/profile/cubit/update_profile_cubit.dart';
import 'package:spora_app/features/profile/cubit/update_profile_state.dart';

class UpdateProfileView extends StatelessWidget {
  const UpdateProfileView({super.key, required this.user});

  final UserData user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdateProfileCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Update Profile")),
        body: BlocConsumer<UpdateProfileCubit, UpdateProfileState>(
          listener: (context, state) {
            if (state is UpdateProfileErrorState) {
              SnackBarPopUp().show(
                context: context,
                message: state.errorMsg,
                state: PopUpState.error,
              );
            } else if (state is UpdateProfileSuccessState) {
              SnackBarPopUp().show(
                context: context,
                message: "Profile Updated Successfully",
                state: PopUpState.success,
              );
              Navigator.pop(context, true);
            }
          },
          builder: (context, state) {
            var cubit = UpdateProfileCubit.get(context);
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: ImageManager(
                          onImageSelected: (pickedFile) {
                            cubit.imagePath = pickedFile;
                          },

                          networkImageBuilder: Image.network(
                            user.avatarUrl,
                            height: 200.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 200.h,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                          ),
                          unselectedImageBuilder: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[400]!,
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Choose Image',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          selectedImageBuilder: (XFile path) {
                            cubit.imagePath = path;
                            return Image.file(
                              File(path.path),
                              height: 200.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        hintText: user.firstName,
                        controller: cubit.firstNameController,
                        validator: AppValidator.validateRequired,
                        labelText: 'First Name',
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: cubit.lastNameController,
                        labelText: "Last Name",
                        hintText: user.lastName,

                        validator: AppValidator.validateRequired,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: cubit.displayNameController,
                        labelText: "Display Name",
                        hintText: user.displayName,

                        validator: AppValidator.validateRequired,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: cubit.phoneNumber,
                        labelText: "Phone Number",
                        hintText: user.mobile,

                        validator: AppValidator.validateRequired,
                      ),
                      SizedBox(height: 15.h),

                      state is UpdateCompanyLoadingState
                          ? const Center(child: CircularProgressIndicator())
                          : AppButton(
                              text: "Update Details",
                              onPressed: () {
                                cubit.updateProfile();
                              },
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
