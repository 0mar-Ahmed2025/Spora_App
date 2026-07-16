import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickAccessTile extends StatelessWidget {
  const QuickAccessTile({
    super.key,
    required this.sporaBackgroundGray,
    required this.sporaPurple,
    required this.sporaTextDark,
    required this.sporaTextMuted,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color sporaBackgroundGray;
  final Color sporaPurple;
  final Color sporaTextDark;
  final Color sporaTextMuted;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: sporaBackgroundGray,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          height: 48.h,
          width: 48.w,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: sporaPurple, size: 24.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: sporaTextDark,
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: sporaTextMuted, fontSize: 12.sp),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14.sp,
          color: sporaTextMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}
