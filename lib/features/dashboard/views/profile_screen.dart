// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/core/shared/custom_button.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';
import 'package:spora_app/features/profile/view/update_profile_screen.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class ProfileScreen extends StatelessWidget {
  final UserData user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.profile_title.tr())),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            ProfileHeaderWidget(user: user, context: context),
            SizedBox(height: 24.h),

            ProfileStatusBadgeWidget(isActive: user.isActive, context: context),
            SizedBox(height: 24.h),

            ProfileInfoCardWidget(user: user, context: context),
            SizedBox(height: 20.h),

            AppButton(
              text: LocaleKeys.profile_update_profile.tr(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return UpdateProfileView(user: user);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoCardWidget extends StatelessWidget {
  const ProfileInfoCardWidget({
    super.key,
    required this.user,
    required this.context,
  });

  final UserData user;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final joinDate =
        "${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}";

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.black
          : AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            ProfileInfoTileWidget(
              context: context,
              icon: Icons.person_outline,
              label: LocaleKeys.full_name.tr(),
              value: '${user.firstName} ${user.lastName}',
            ),
            const Divider(height: 20),
            ProfileInfoTileWidget(
              context: context,
              icon: Icons.phone_android_outlined,
              label: LocaleKeys.phone_number.tr(),
              value: user.mobile.isNotEmpty
                  ? user.mobile
                  : LocaleKeys.unknown.tr(),
            ),
            const Divider(height: 20),
            ProfileInfoTileWidget(
              context: context,
              icon: Icons.language,
              label: LocaleKeys.language.tr(),
              value: user.locale.toUpperCase(),
            ),
            const Divider(height: 20),
            ProfileInfoTileWidget(
              context: context,
              icon: Icons.public,
              label: LocaleKeys.timezone.tr(),
              value: user.timezone.isEmpty ? "Asia" : user.timezone,
            ),
            const Divider(height: 20),
            ProfileInfoTileWidget(
              context: context,
              icon: Icons.calendar_today_outlined,
              label: LocaleKeys.join_date.tr(),
              value: joinDate,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoTileWidget extends StatelessWidget {
  const ProfileInfoTileWidget({
    super.key,
    required this.context,
    required this.icon,
    required this.label,
    required this.value,
  });

  final BuildContext context;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20.r),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileStatusBadgeWidget extends StatelessWidget {
  const ProfileStatusBadgeWidget({
    super.key,
    required this.isActive,
    required this.context,
  });

  final bool isActive;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.12)
            : Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.error,
            color: isActive ? Colors.green : Colors.red,
            size: 18.r,
          ),
          SizedBox(width: 8.w),
          Text(
            isActive
                ? LocaleKeys.profile_active_account.tr()
                : LocaleKeys.profile_unactive_account.tr(),
            style: TextStyle(
              color: isActive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.context,
  });

  final UserData user;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                child: Text(
                  '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (user.isActive)
                CircleAvatar(
                  radius: 12.r,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  child: CircleAvatar(
                    radius: 9.r,
                    backgroundColor: Colors.green,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text(user.displayName),
        SizedBox(height: 6.h),
        Text(user.email),
      ],
    );
  }
}
