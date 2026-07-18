import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/core/shared/logout_button.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/features/dashboard/cubits/get_profile_data/get_profile_cubit.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';
import 'package:spora_app/features/profile/view/profile_screen.dart';
import 'package:spora_app/features/dashboard/views/security_view.dart';
import 'package:spora_app/features/dashboard/widgets/custom_account_status_widget.dart';
import 'package:spora_app/features/dashboard/widgets/custom_app_bar_widget.dart';
import 'package:spora_app/features/dashboard/widgets/quick_access_tile_widget.dart';
import 'package:spora_app/features/settings/view/setting_view.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class DashboardSuccessStateWidget extends StatelessWidget {
  const DashboardSuccessStateWidget({
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
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ProfileScreen();
                  },
                ),
              );

              if (context.mounted) {
                GetProfileCubit.get(context).getProfileData();
              }
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
          const LogoutButton(),
        ],
      ),
    );
  }
}
