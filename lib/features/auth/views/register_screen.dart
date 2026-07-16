// ignore_for_file: unused_local_variable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:spora_app/core/constants/app_assets.dart';
import 'package:spora_app/core/helper/app_validator.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/core/shared/custom_button.dart';
import 'package:spora_app/core/shared/custom_text_button.dart';
import 'package:spora_app/core/shared/custom_textfield.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/features/auth/cubits/login/login_state.dart';
import 'package:spora_app/features/auth/cubits/register/register_cubit.dart';
import 'package:spora_app/features/auth/cubits/register/register_state.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterFailure) {
              // SnackBarPopUp().show(
              //   context: context,
              //   message: state.error,
              //   state: PopUpState.error,
              // );
              GoRouter.of(context).push(AppRoutes.accountCreatedScreen);
            } else if (state is RegisterSuccess) {
              // SnackBarPopUp().show(
              //   context: context,
              //   message: 'Register successfully!',
              //   state: PopUpState.success,
              // );
              context.go(AppRoutes.accountCreatedScreen);
            }
          },
          builder: (context, state) {
            var cubit = RegisterCubit.get(context);

            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Form(
                    key: cubit.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.h),
                        Container(
                          height: 180.h,
                          width: 150.w,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage(AppAssets.logo),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        Text(
                          LocaleKeys.register_title.tr(),
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(LocaleKeys.register_already_have_account.tr()),
                            CustomTextBtn(
                              text: LocaleKeys.register_sign_in.tr(),
                              onPressed: () {
                                GoRouter.of(context).pop();
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),
                        CustomTextField(
                          controller: cubit.username,
                          labelText: LocaleKeys.full_name.tr(),
                          keyboardType: TextInputType.name,
                          validator: AppValidator.validateRequired,
                          suffixIcon: const IconButton(
                            onPressed: null,
                            icon: Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField(
                          controller: cubit.email,
                          labelText: LocaleKeys.register_your_email.tr(),
                          keyboardType: TextInputType.emailAddress,
                          validator: AppValidator.validateRequired,
                          suffixIcon: const IconButton(
                            onPressed: null,
                            icon: Icon(Icons.email, color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField(
                          controller: cubit.password,
                          labelText: LocaleKeys.password.tr(),
                          obscureText: cubit.passwordSecure,
                          keyboardType: TextInputType.visiblePassword,
                          validator: AppValidator.validateRequired,
                          suffixIcon: IconButton(
                            onPressed: cubit.changePasswordVisibility,
                            icon: Icon(
                              cubit.passwordSecure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField(
                          controller: cubit.confirmPassword,
                          labelText: LocaleKeys.register_retype_password.tr(),
                          obscureText: cubit.confirmPasswordSecure,
                          keyboardType: TextInputType.visiblePassword,
                          validator: AppValidator.validateRequired,
                          suffixIcon: IconButton(
                            onPressed: cubit.confirmPasswordVisibility,
                            icon: Icon(
                              cubit.confirmPasswordSecure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        state is LoginLoadingState
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: const CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : AppButton(
                                text: LocaleKeys.register_btn.tr(),
                                onPressed: cubit.register,
                              ),
                      ],
                    ),
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
