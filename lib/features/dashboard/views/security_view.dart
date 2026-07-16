// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.security_title.tr())),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            SettingsTile(
              icon: Icons.lock_outline_rounded,
              iconColor: Colors.orange,
              title: LocaleKeys.security_password_title.tr(),
              subtitle: LocaleKeys.security_password_subtitle.tr(),
              onTap: () {
                GoRouter.of(context).push(AppRoutes.changePasswordScreen);
              },
            ),
            SettingsDivider(),
            SettingsTile(
              icon: Icons.security,
              iconColor: Colors.purple,
              title: LocaleKeys.security_mfa_title.tr(),
              subtitle: LocaleKeys.security_mfa_subtitle.tr(),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTileIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const SettingsTileIcon({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: color, size: 22.r),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: SettingsTileIcon(icon: icon, color: iconColor),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 15.sp,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14.r,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
      onTap: onTap,
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 56.w,
      endIndent: 16.w,
      color: Colors.grey.withOpacity(0.15),
    );
  }
}
