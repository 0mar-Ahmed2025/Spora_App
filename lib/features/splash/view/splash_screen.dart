import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:spora_app/core/cache/cache_helper.dart';
import 'package:spora_app/core/constants/app_assets.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: const Offset(0, 0.1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final token = await CacheHelper().getAccessToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      GoRouter.of(context).go(AppRoutes.dashboardScreen);
    } else {
      GoRouter.of(context).go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _animation,
              child: Image.asset(AppAssets.logo, height: 180.h, width: 180.w),
            ),
            SizedBox(height: 20.h),
            Text(
              LocaleKeys.spora.tr(),
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 80.h),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
