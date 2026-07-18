import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/core/helper/app_pop_up.dart';
import 'package:spora_app/core/helper/app_validator.dart';
import 'package:spora_app/core/shared/custom_button.dart';
import 'package:spora_app/core/shared/custom_textfield.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';
import 'package:spora_app/features/profile/cubit/update_profile/update_profile_cubit.dart';
import 'package:spora_app/features/profile/cubit/update_profile/update_profile_state.dart';

class UpdateProfileView extends StatelessWidget {
  const UpdateProfileView({super.key, required this.user});

  final UserData user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        var cubit = UpdateProfileCubit();
        cubit.firstNameController.text = user.firstName;
        cubit.lastNameController.text = user.lastName;
        cubit.displayNameController.text = user.displayName;
        cubit.phoneNumber.text = user.mobile;
        return cubit;
      },
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
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: cubit.firstNameController,
                        validator: AppValidator.validateRequired,
                        labelText: 'First Name',
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: cubit.lastNameController,
                        labelText: "Last Name",
                        validator: AppValidator.validateRequired,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: cubit.displayNameController,
                        labelText: "Display Name",
                        validator: AppValidator.validateRequired,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: cubit.phoneNumber,
                        labelText: "Phone Number",
                        validator: AppValidator.validateRequired,
                      ),

                      SizedBox(height: 15.h),
                      state is UpdateProfileLoadingState
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
