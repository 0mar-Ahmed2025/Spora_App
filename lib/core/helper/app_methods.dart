// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:spora_app/core/helper/app_pop_up.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/features/auth/cubits/logout/logout_cubit.dart';
import 'package:spora_app/features/auth/cubits/logout/logout_state.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

abstract class AppMethods {
  static void showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return BlocProvider(
          create: (context) => LogoutCubit(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: BlocConsumer<LogoutCubit, LogoutState>(
              listener: (context, state) {
                if (state is LogoutSuccess) {
                  context.go(AppRoutes.login);
                } else if (state is LogoutFailure) {
                  SnackBarPopUp().show(
                    context: context,
                    message: state.message,
                    state: PopUpState.error,
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 64.h,
                      width: 64.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFECEF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      LocaleKeys.logout_confirm_title.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      LocaleKeys.logout_confirm_subtitle.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    state is LogoutLoading
                        ? Center(child: CircularProgressIndicator())
                        : Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 52.h,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      LocaleKeys.cancel.tr(),
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: SizedBox(
                                  height: 52.h,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      context.read<LogoutCubit>().logout();
                                    },
                                    child: Text(
                                      LocaleKeys.logout.tr(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  static void showLanguageDialog(BuildContext context) {
    final currentLangCode = context.locale.languageCode;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(LocaleKeys.settings_select_language.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: currentLangCode,
                onChanged: (value) {
                  if (value != null) {
                    context.setLocale(const Locale('en'));
                    Navigator.pop(dialogContext);
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('العربية'),
                value: 'ar',
                groupValue: currentLangCode,
                onChanged: (value) {
                  if (value != null) {
                    context.setLocale(const Locale('ar'));
                    Navigator.pop(dialogContext);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String getInitials(UserData userData) {
    String initials = "";
    if (userData.firstName.isNotEmpty) initials += userData.firstName[0];
    if (userData.lastName.isNotEmpty) initials += userData.lastName[0];
    return initials.isEmpty ? "?" : initials.toUpperCase();
  }
}
