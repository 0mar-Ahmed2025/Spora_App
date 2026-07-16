import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:spora_app/core/constants/app_assets.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/core/shared/custom_button.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class CheckYourEmailScreen extends StatelessWidget {
  const CheckYourEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              SizedBox(height: 40.h),

              Text(
                LocaleKeys.check_your_email_title.tr(),
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
                child: Text(
                  textAlign: TextAlign.center,
                  LocaleKeys.check_your_email_description.tr(),
                ),
              ),
              SizedBox(height: 70.h),

              AppButton(
                text: LocaleKeys.confirm.tr(),
                onPressed: () {
                  GoRouter.of(context).pushReplacement(AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
