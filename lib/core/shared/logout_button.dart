import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/core/helper/app_methods.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          AppMethods.showLogoutConfirmation(context);
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.red),
        label: Text(
          LocaleKeys.logout.tr(),
          style: TextStyle(
            color: Colors.red,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
