// ignore_for_file: unused_local_variable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:spora_app/core/helper/app_pop_up.dart';
import 'package:spora_app/core/helper/app_validator.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/core/shared/custom_button.dart';
import 'package:spora_app/core/shared/custom_logo.dart';
import 'package:spora_app/core/shared/custom_textfield.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/features/auth/cubits/login/login_cubit.dart';
import 'package:spora_app/features/auth/cubits/login/login_state.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<LoginCubit, LoginStates>(
          listener: (context, state) {
            if (state is LoginErrorState) {
              SnackBarPopUp().show(
                context: context,
                message: state.error,
                state: PopUpState.error,
              );
            } else if (state is LoginMfaRequiredState) {
              SnackBarPopUp().show(
                context: context,
                message: LocaleKeys.login_mfa_required.tr(),
                state: PopUpState.warning,
              );
              context.push(AppRoutes.mfaScreen, extra: state.mfaToken);
            } else if (state is LoginSuccessState) {
              SnackBarPopUp().show(
                context: context,
                message: LocaleKeys.login_success.tr(),
                state: PopUpState.success,
              );
              context.go(AppRoutes.dashboardScreen);
            }
          },
          builder: (context, state) {
            var cubit = LoginCubit.get(context);

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
                        SizedBox(height: 50.h),
                        CustomLogo(),

                        Text(
                          LocaleKeys.login_title.tr(),
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),

                        SizedBox(height: 30.h),
                        CustomTextField(
                          controller: cubit.email,
                          labelText: LocaleKeys.email.tr(),
                          keyboardType: TextInputType.emailAddress,
                          validator: AppValidator.validateRequired,
                          suffixIcon: const IconButton(
                            onPressed: null,
                            icon: Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
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
                        SizedBox(height: 40.h),
                        state is LoginLoadingState
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: const CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : AppButton(
                                text: LocaleKeys.login_btn.tr(),
                                onPressed: cubit.login,
                              ),

                        SizedBox(height: 20.h),
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
