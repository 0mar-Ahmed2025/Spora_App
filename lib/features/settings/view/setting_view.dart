// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/core/helper/app_methods.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/core/theme/theme_cubit.dart';
import 'package:spora_app/features/settings/view/about_app_screen.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDarkMode = themeMode == ThemeMode.dark;
    final isArabic = context.locale.languageCode == 'ar';
    final languageName = isArabic ? 'العربية' : 'English';

    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.settings_title.tr())),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: LocaleKeys.settings_preferences.tr()),
            SizedBox(height: 8.h),
            SettingsGroup(
              children: [
                SettingsSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  iconColor: Colors.purple,
                  title: LocaleKeys.settings_dark_mode_title.tr(),
                  subtitle: LocaleKeys.settings_dark_mode_subtitle.tr(),
                  value: isDarkMode,
                  onChanged: (bool value) {
                    context.read<ThemeCubit>().changeTheme(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.language_rounded,
                  iconColor: Colors.teal,
                  title: LocaleKeys.settings_language.tr(),
                  subtitle: languageName,
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.r,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => _showLanguageDialog(context),
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  iconColor: Colors.redAccent,
                  title: LocaleKeys.settings_notifications_title.tr(),
                  subtitle: LocaleKeys.settings_notifications_subtitle.tr(),
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SectionHeader(title: LocaleKeys.settings_support_help.tr()),
            SizedBox(height: 8.h),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: Colors.green,
                  title: LocaleKeys.settings_help_center_title.tr(),
                  subtitle: LocaleKeys.settings_help_center_subtitle.tr(),
                  onTap: () {},
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.blueGrey,
                  title: LocaleKeys.settings_about_app_title.tr(),
                  subtitle: LocaleKeys.settings_about_app_subtitle.tr(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutAppScreen()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 32.h),
            const LogoutButton(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
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
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const SettingsGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
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

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      secondary: SettingsTileIcon(icon: icon, color: iconColor),
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
      value: value,
      activeColor: Theme.of(context).primaryColor,
      onChanged: onChanged,
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
