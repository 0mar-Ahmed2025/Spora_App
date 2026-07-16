import 'package:go_router/go_router.dart';
import 'package:spora_app/core/cache/cache_helper.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/features/auth/views/account_created_screen.dart';
import 'package:spora_app/features/auth/views/check_your_email_screen.dart';
import 'package:spora_app/features/auth/views/login_screen.dart';
import 'package:spora_app/features/auth/views/mfa_screen.dart';
import 'package:spora_app/features/auth/views/register_screen.dart';
import 'package:spora_app/features/auth/views/reset_password_screen.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';
import 'package:spora_app/features/dashboard/views/dashboard_view.dart';
import 'package:spora_app/features/dashboard/views/profile_screen.dart';
import 'package:spora_app/features/dashboard/views/security_view.dart';
import 'package:spora_app/features/settings/view/change_password_screen.dart';
import 'package:spora_app/features/splash/view/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashScreen,
    redirect: (context, state) async {
      final token = await CacheHelper().getAccessToken();
      final isLoggedIn = token != null && token.isNotEmpty;

      final isGoingToLogin = state.matchedLocation == AppRoutes.login;
      final isGoingToSplash = state.matchedLocation == AppRoutes.splashScreen;

      if (!isLoggedIn && !isGoingToLogin && !isGoingToSplash) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isGoingToLogin) {
        return AppRoutes.dashboardScreen;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileScreen,
        builder: (context, state) {
          final user = state.extra as UserData;
          return ProfileScreen(user: user);
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.mfaScreen,
        builder: (context, state) => const MfaVerificationView(),
      ),
      GoRoute(
        path: AppRoutes.dashboardScreen,
        builder: (context, state) => const DashboardView(),
      ),
      GoRoute(
        path: AppRoutes.registerScreen,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountCreatedScreen,
        builder: (context, state) => const AccountCreatedScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPasswordScreen,
        builder: (context, state) => ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkYourEmailScreen,
        builder: (context, state) => const CheckYourEmailScreen(),
      ),
      GoRoute(
        path: AppRoutes.securityScreen,
        builder: (context, state) => const SecurityView(),
      ),
      GoRoute(
        path: AppRoutes.changePasswordScreen,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      // GoRoute(
      //   path: AppRoutes.updateProfileScreen,
      //   builder: (context, state) => const UpdateProfileView(),
      // ),
    ],
  );
}
