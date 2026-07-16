// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/core/helper/app_methods.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/features/dashboard/cubits/get_profile_data/get_profile_cubit.dart';
import 'package:spora_app/features/dashboard/cubits/get_profile_data/get_profile_state.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';
import 'package:spora_app/features/dashboard/views/profile_screen.dart';
import 'package:spora_app/features/dashboard/views/security_view.dart';
import 'package:spora_app/features/dashboard/widgets/custom_account_status_widget.dart';
import 'package:spora_app/features/dashboard/widgets/custom_app_bar_widget.dart';
import 'package:spora_app/features/dashboard/widgets/quick_access_tile_widget.dart';
import 'package:spora_app/features/settings/view/setting_view.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetProfileCubit()..getProfileData(),
      child: Scaffold(
        body: BlocBuilder<GetProfileCubit, GetProfileState>(
          builder: (context, state) {
            var cubit = GetProfileCubit.get(context);
            if (state is GetProfileErrorState) {
              return CustomErrorStateWidget(cubit: cubit);
            } else if (state is GetProfileLoadingState) {
              return CustomLoadingWidget();
            } else if (state is EmptyProfileState) {
              return Container(color: Colors.red);
            } else if (state is GetProfileSuccessState) {
              return CustomSuccessStateWidget(
                context: context,
                user: state.userModel,
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}

class CustomErrorStateWidget extends StatelessWidget {
  const CustomErrorStateWidget({super.key, required this.cubit});

  final GetProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80.h,
              width: 80.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECEF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              LocaleKeys.dashboard_error_loading.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              LocaleKeys.dashboard_connect_internet.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 160.w,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  Future.delayed(const Duration(seconds: 2), () {
                    cubit.getProfileData();
                  });
                },
                child: Text(
                  LocaleKeys.retry.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSuccessStateWidget extends StatelessWidget {
  const CustomSuccessStateWidget({
    super.key,
    required this.context,
    required this.user,
  });

  final BuildContext context;
  final UserData user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(userData: user, imageUrl: user.avatarUrl),
          SizedBox(height: 24.h),

          CustomAccountStatus(isActive: user.isActive),
          SizedBox(height: 32.h),

          Text(
            LocaleKeys.dashboard_quick_actions.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          QuickAccessTile(
            sporaBackgroundGray: AppColors.background,
            sporaPurple: AppColors.primary,
            sporaTextDark: AppColors.textPrimary,
            sporaTextMuted: AppColors.textSecondary,
            icon: Icons.person_search_outlined,
            title: LocaleKeys.dashboard_profile_title.tr(),
            subtitle: LocaleKeys.dashboard_profile_subtitle.tr(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ProfileScreen(user: user);
                  },
                ),
              );
            },
          ),
          SizedBox(height: 12.h),
          QuickAccessTile(
            sporaBackgroundGray: AppColors.background,
            sporaPurple: AppColors.primary,
            sporaTextDark: AppColors.textPrimary,
            sporaTextMuted: AppColors.textSecondary,
            icon: Icons.security_outlined,
            title: LocaleKeys.dashboard_security_title.tr(),
            subtitle: LocaleKeys.dashboard_security_subtitle.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SecurityView();
                  },
                ),
              );
            },
          ),
          SizedBox(height: 12.h),
          QuickAccessTile(
            sporaBackgroundGray: AppColors.background,
            sporaPurple: AppColors.primary,
            sporaTextDark: AppColors.textPrimary,
            sporaTextMuted: AppColors.textSecondary,
            icon: Icons.settings_outlined,
            title: LocaleKeys.dashboard_settings_title.tr(),
            subtitle: LocaleKeys.dashboard_settings_subtitle.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsScreen();
                  },
                ),
              );
            },
          ),
          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFECEF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              onPressed: () {
                AppMethods.showLogoutConfirmation(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  SizedBox(width: 8.w),
                  Text(
                    LocaleKeys.logout.tr(),
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}
