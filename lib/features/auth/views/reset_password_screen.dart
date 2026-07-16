import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:spora_app/core/constants/app_assets.dart';
import 'package:spora_app/core/helper/app_validator.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/core/shared/custom_button.dart';
import 'package:spora_app/core/shared/custom_text_button.dart';
import 'package:spora_app/core/shared/custom_textfield.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});

  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100.h),
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
                  SizedBox(height: 30.h),

                  Text(
                    LocaleKeys.reset_password_title.tr(),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  SizedBox(
                    height: 46.h,
                    width: 300.w,
                    child: Text(LocaleKeys.reset_password_description.tr()),
                  ),
                  SizedBox(height: 50.h),
                  CustomTextField(
                    controller: emailController,
                    labelText: LocaleKeys.register_your_email.tr(),
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidator.validateRequired,
                    suffixIcon: const IconButton(
                      onPressed: null,
                      icon: Icon(Icons.email, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  AppButton(
                    text: "continue",
                    onPressed: () {
                      if (formKey.currentState?.validate() == false) return;
                      GoRouter.of(context).go(AppRoutes.checkYourEmailScreen);
                    },
                  ),
                  SizedBox(height: 30.h),

                  CustomTextBtn(
                    text: "return to sign in",
                    onPressed: () {
                      GoRouter.of(context).go(AppRoutes.login);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
