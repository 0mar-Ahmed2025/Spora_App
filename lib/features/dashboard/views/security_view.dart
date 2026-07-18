// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/features/settings/view/setting_view.dart';
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
              onTap: () {
                GoRouter.of(context).push(AppRoutes.mfaSettingsScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}
