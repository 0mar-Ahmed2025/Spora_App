import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/core/helper/app_pop_up.dart';
import 'package:spora_app/core/helper/app_validator.dart';
import 'package:spora_app/core/shared/custom_button.dart';
import 'package:spora_app/core/shared/custom_textfield.dart';
import 'package:spora_app/features/settings/cubits/change_password/change_password_cubit.dart';
import 'package:spora_app/features/settings/cubits/change_password/change_password_state.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangePasswordCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Change Password'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
          listener: (context, state) {
            if (state is ChangePasswordSuccess) {
              SnackBarPopUp().show(
                context: context,
                message: "Password Changed Successfully",
                state: PopUpState.success,
              );
              Navigator.pop(context);
            } else if (state is ChangePasswordError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<ChangePasswordCubit>();
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Form(
                key: cubit.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: cubit.currentPasswordController,
                      labelText: 'Current Password',
                      validator: AppValidator.validateRequired,
                    ),
                    SizedBox(height: 20.h),
                    CustomTextField(
                      controller: cubit.newPasswordController,
                      labelText: 'New Password',
                      validator: AppValidator.validateRequired,
                    ),
                    SizedBox(height: 20.h),
                    CustomTextField(
                      controller: cubit.confirmPasswordController,
                      labelText: 'Confirm New Password',
                      validator: AppValidator.validateRequired,
                    ),
                    SizedBox(height: 20.h),

                    CustomTextField(
                      controller: cubit.mfaCode,
                      labelText: 'MFA Code',
                      validator: AppValidator.validateRequired,
                    ),
                    SizedBox(height: 40.h),
                    state is ChangePasswordLoading
                        ? Center(child: CircularProgressIndicator())
                        : AppButton(
                            onPressed: cubit.changePassword,
                            text: 'Change Password',
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
