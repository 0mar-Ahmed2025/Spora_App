import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/core/constants/app_assets.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.h,
      width: 150.w,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(AppAssets.logo),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
