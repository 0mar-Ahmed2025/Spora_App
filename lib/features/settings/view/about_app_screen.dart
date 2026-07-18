// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppInfoHeader(),
            SizedBox(height: 40.h),
            AboutSectionGroup(
              children: [
                AboutActionTile(
                  icon: Icons.description_outlined,
                  title: 'Terms and Conditions',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')),
                    );
                  },
                ),
                const AboutDivider(),
                AboutActionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')),
                    );
                  },
                ),
                const AboutDivider(),
                AboutActionTile(
                  icon: Icons.article_outlined,
                  title: 'Open Source Licenses',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 40.h),
            const AppFooterText(),
          ],
        ),
      ),
    );
  }
}

class AppInfoHeader extends StatelessWidget {
  const AppInfoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Icon(
            Icons.rocket_launch_rounded,
            size: 48.r,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Maya Core',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22.sp,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Version 1.0.0 (Build 1)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}

class AboutSectionGroup extends StatelessWidget {
  final List<Widget> children;

  const AboutSectionGroup({super.key, required this.children});

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
      child: Column(
        children: children,
      ),
    );
  }
}

class AboutActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const AboutActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
        size: 24.r,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14.r,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

class AboutDivider extends StatelessWidget {
  const AboutDivider({super.key});

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

class AppFooterText extends StatelessWidget {
  const AppFooterText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '© ${DateTime.now().year} Maya Platform. All rights reserved.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
      textAlign: TextAlign.center,
    );
  }
}