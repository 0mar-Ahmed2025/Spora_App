import 'package:spora_app/core/routing/app_routes.dart';

String? resolveAuthRedirect({
  required bool isLoggedIn,
  required String matchedLocation,
}) {
  final isGoingToLogin = matchedLocation == AppRoutes.login;
  final isGoingToSplash = matchedLocation == AppRoutes.splashScreen;
  final isGoingToMfa = matchedLocation == AppRoutes.mfaScreen;

  final isPublicRoute = isGoingToLogin || isGoingToSplash || isGoingToMfa;

  if (!isLoggedIn && !isPublicRoute) {
    return AppRoutes.login;
  }

  if (isLoggedIn && isGoingToLogin) {
    return AppRoutes.dashboardScreen;
  }

  return null;
}
