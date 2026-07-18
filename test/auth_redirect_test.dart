import 'package:flutter_test/flutter_test.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/core/routing/auth_redirect.dart';

void main() {
  group('resolveAuthRedirect', () {
    test('allows unauthenticated user to open MFA screen', () {
      expect(
        resolveAuthRedirect(
          isLoggedIn: false,
          matchedLocation: AppRoutes.mfaScreen,
        ),
        isNull,
      );
    });

    test('allows unauthenticated user to open login and reset password', () {
      expect(
        resolveAuthRedirect(
          isLoggedIn: false,
          matchedLocation: AppRoutes.login,
        ),
        isNull,
      );
    });

    test('redirects unauthenticated user away from dashboard', () {
      expect(
        resolveAuthRedirect(
          isLoggedIn: false,
          matchedLocation: AppRoutes.dashboardScreen,
        ),
        AppRoutes.login,
      );
    });

    test('redirects authenticated user away from login to dashboard', () {
      expect(
        resolveAuthRedirect(isLoggedIn: true, matchedLocation: AppRoutes.login),
        AppRoutes.dashboardScreen,
      );
    });

    test('allows authenticated user to open dashboard', () {
      expect(
        resolveAuthRedirect(
          isLoggedIn: true,
          matchedLocation: AppRoutes.dashboardScreen,
        ),
        isNull,
      );
    });
  });
}
