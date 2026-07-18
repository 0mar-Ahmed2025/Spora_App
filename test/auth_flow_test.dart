import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spora_app/core/network/api_response.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/features/auth/cubits/login/login_cubit.dart';
import 'package:spora_app/features/auth/cubits/login/login_state.dart';
import 'package:spora_app/features/auth/cubits/logout/logout_cubit.dart';
import 'package:spora_app/features/auth/cubits/logout/logout_state.dart';
import 'package:spora_app/features/auth/cubits/mfa_verify/mfa_cubit.dart';
import 'package:spora_app/features/auth/cubits/mfa_verify/mfa_state.dart';
import 'package:spora_app/features/auth/cubits/reset_password/reset_password_cubit.dart';
import 'package:spora_app/features/auth/cubits/reset_password/reset_password_state.dart';
import 'package:spora_app/features/auth/data/models/auth_response_model.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';

import 'fakes/fake_auth_repository.dart';
import 'fakes/memory_auth_storage.dart';

Future<void> _loadTestEnv() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.loadFromString(
    envString: '''
BASE_URL=https://example.com/v1/
MFA_RESEND_ENABLED=false
REGISTER_ENABLED=false
''',
  );
}

void main() {
  setUpAll(_loadTestEnv);

  group('Auth flow models', () {
    test('parses mfa required login response', () {
      final model = AuthResponseModel.fromJson({
        'mfa_required': true,
        'mfa_token': 'mfa-test-token',
        'methods': ['email'],
      });

      expect(model.mfaRequired, true);
      expect(model.mfaToken, 'mfa-test-token');
      expect(model.accessToken, isNull);
    });

    test('parses success login response with tokens', () {
      final model = AuthResponseModel.fromJson({
        'mfa_required': false,
        'access_token': 'access-123',
        'refresh_token': 'refresh-456',
        'expires_in': 3600,
      });

      expect(model.mfaRequired, false);
      expect(model.accessToken, 'access-123');
      expect(model.refreshToken, 'refresh-456');
    });

    test('user model parses safely when dates are missing', () {
      final user = UserData.fromJson({
        'id': '1',
        'email': 'test@mail.com',
        'display_name': 'Test User',
        'first_name': 'Test',
        'last_name': 'User',
        'locale': 'en',
        'avatar_url': '',
        'timezone': 'UTC',
        'mobile': '0100',
        'theme': 'light',
        'is_active': true,
      });

      expect(user.email, 'test@mail.com');
      expect(user.displayName, 'Test User');
      expect(user.isActive, true);
    });
  });

  group('Login → MFA → Dashboard → Logout flow', () {
    test('login stores mfa token when MFA is required', () async {
      final storage = MemoryAuthStorage();
      final cubit = LoginCubit(
        storage: storage,
        repo: FakeAuthRepository(
          onLogin: ({required email, required password}) async {
            return ApiResponse(
              status: true,
              statusCode: 200,
              message: 'Success',
              data: {'mfa_required': true, 'mfa_token': 'mfa-token-123'},
            );
          },
        ),
      );

      cubit.email.text = 'user@test.com';
      cubit.password.text = 'password123';
      await cubit.login();

      expect(cubit.state, isA<LoginMfaRequiredState>());
      expect(await storage.getMfaToken(), 'mfa-token-123');
      expect(await storage.getAccessToken(), isNull);
      await cubit.close();
    });

    test('MFA verification stores access token and clears mfa token', () async {
      final storage = MemoryAuthStorage();
      await storage.saveMfaToken('mfa-token-123');

      final cubit = MfaCubit(
        storage: storage,
        repo: FakeAuthRepository(
          onVerifyMfa: ({required code, mfaToken}) async {
            expect(code, '123456');
            expect(mfaToken, 'mfa-token-123');
            return ApiResponse(
              status: true,
              statusCode: 200,
              message: 'Success',
              data: {
                'access_token': 'access-token',
                'refresh_token': 'refresh-token',
              },
            );
          },
        ),
      );

      cubit.mfaCode.text = '123456';
      await cubit.verifyMfa(mfaToken: 'mfa-token-123');

      expect(cubit.state, isA<MfaSuccessState>());
      expect(await storage.getAccessToken(), 'access-token');
      expect(await storage.getRefreshToken(), 'refresh-token');
      expect(await storage.getMfaToken(), isNull);
      await cubit.close();
    });

    test('logout clears stored auth data', () async {
      final storage = MemoryAuthStorage();
      await storage.saveTokens('access-token', refreshToken: 'refresh-token');

      final cubit = LogoutCubit(
        storage: storage,
        authRepository: FakeAuthRepository(
          onLogout: ({required refreshToken}) async {
            expect(refreshToken, 'refresh-token');
            return ApiResponse(
              status: true,
              statusCode: 200,
              message: 'Success',
            );
          },
        ),
      );

      await cubit.logout();

      expect(cubit.state, isA<LogoutSuccess>());
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(await storage.getMfaToken(), isNull);
      await cubit.close();
    });

    test('resend MFA is blocked when feature flag is disabled', () async {
      final cubit = MfaCubit(
        storage: MemoryAuthStorage(),
        repo: FakeAuthRepository(
          onResendMfa: ({required mfaToken}) async {
            fail('API should not be called when resend is disabled');
          },
        ),
      );

      await cubit.resendMfa(mfaToken: 'mfa-token-123');

      expect(cubit.state, isA<MfaResendErrorState>());
      await cubit.close();
    });
  });

  group('Reset password', () {
    test('submits forgot password request successfully', () async {
      final cubit = ResetPasswordCubit(
        repo: FakeAuthRepository(
          onForgotPassword: ({required email}) async {
            expect(email, 'user@test.com');
            return ApiResponse(
              status: true,
              statusCode: 200,
              message: 'Email sent',
            );
          },
        ),
      );

      cubit.emailController.text = 'user@test.com';
      await cubit.submitResetRequest();

      expect(cubit.state, isA<ResetPasswordSuccess>());
      await cubit.close();
    });
  });

  group('App routes', () {
    test('auth and dashboard routes are defined', () {
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.mfaScreen, '/mfaScreen');
      expect(AppRoutes.dashboardScreen, '/dashboardScreen');
      expect(AppRoutes.splashScreen, '/splashScreen');
    });
  });
}
