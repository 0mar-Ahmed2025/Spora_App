import 'package:go_router/go_router.dart';
import 'package:spora_app/core/cache/cache_helper.dart';
import 'package:spora_app/core/routing/auth_redirect.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/features/auth/views/login_screen.dart';
import 'package:spora_app/features/auth/views/mfa_screen.dart';
import 'package:spora_app/features/dashboard/views/dashboard_view.dart';
import 'package:spora_app/features/dashboard/views/security_view.dart';
import 'package:spora_app/features/profile/view/profile_screen.dart';
import 'package:spora_app/features/settings/view/change_password_screen.dart';
import 'package:spora_app/features/settings/view/mfa_settings_screen.dart';
import 'package:spora_app/features/splash/view/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashScreen,
    redirect: (context, state) async {
      final token = await CacheHelper().getAccessToken();
      final isLoggedIn = token != null && token.isNotEmpty;

      return resolveAuthRedirect(
        isLoggedIn: isLoggedIn,
        matchedLocation: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileScreen,
        builder: (context, state) {
          return ProfileScreen();
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
      ),      GoRoute(
        path: AppRoutes.securityScreen,
        builder: (context, state) => const SecurityView(),
      ),
      GoRoute(
        path: AppRoutes.changePasswordScreen,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.mfaSettingsScreen,
        builder: (context, state) => const MfaSettingsScreen(),
      ),
    ],
  );
}
