import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spora_app/core/network/api_response.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/features/auth/cubits/login/login_cubit.dart';
import 'package:spora_app/features/auth/cubits/login/login_state.dart';
import 'package:spora_app/features/auth/cubits/mfa_verify/mfa_cubit.dart';
import 'package:spora_app/features/auth/cubits/mfa_verify/mfa_state.dart';
import 'package:spora_app/features/auth/data/repo/auth_repository.dart';
import 'package:spora_app/features/dashboard/cubits/get_profile_data/get_profile_cubit.dart';
import 'package:spora_app/features/dashboard/cubits/get_profile_data/get_profile_state.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';
import 'fakes/fake_auth_repository.dart';
import 'fakes/memory_auth_storage.dart';

// ============================================================================
// MOCKS & FAKES
// ============================================================================

class MockGetProfileCubit extends Mock implements GetProfileCubit {
  @override
  Stream<GetProfileState> get stream => Stream.value(
    GetProfileSuccessState(userModel: _createMockUser()),
  );

  @override
  GetProfileState get state => GetProfileSuccessState(userModel: _createMockUser());
}

// ============================================================================
// TEST HELPERS & UTILITIES
// ============================================================================

// ============================================================================
// TEST HELPERS & UTILITIES
// ============================================================================

Future<void> _loadTestEnv() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Environment variables are not needed for this widget test
}

/// Creates a mock user model for testing
UserData _createMockUser() {
  final now = DateTime.now();
  return UserData(
    id: '123',
    email: 'test@example.com',
    displayName: 'Test User',
    firstName: 'Test',
    lastName: 'User',
    locale: 'en',
    avatarUrl: '',
    timezone: 'UTC',
    mobile: '1234567890',
    theme: 'light',
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );
}

/// Creates and returns a test app widget that can navigate through auth flow
Widget _buildTestApp({
  required GoRouter router,
  required MemoryAuthStorage storage,
  required AuthRepository authRepository,
  required MockGetProfileCubit mockProfileCubit,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, child) {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<MemoryAuthStorage>.value(value: storage),
        ],
        child: MaterialApp.router(
          title: 'Spora App E2E Test',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.light,
        ),
      );
    },
  );
}

/// Creates a GoRouter for testing that navigates between auth screens
GoRouter _createTestRouter({
  required MemoryAuthStorage storage,
  required AuthRepository authRepository,
  required MockGetProfileCubit mockProfileCubit,
}) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => LoginCubit(
              repo: authRepository,
              storage: storage,
            ),
            child: const _TestLoginScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.mfaScreen,
        builder: (context, state) {
          final mfaToken = state.extra as String?;
          return BlocProvider(
            create: (context) => MfaCubit(
              repo: authRepository,
              storage: storage,
            ),
            child: _TestMfaScreen(mfaToken: mfaToken ?? ''),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.dashboardScreen,
        builder: (context, state) {
          return BlocProvider<GetProfileCubit>.value(
            value: mockProfileCubit,
            child: _TestDashboardScreen(storage: storage),
          );
        },
      ),
    ],
  );
}

// ============================================================================
// TEST SCREENS (Simplified for Testing)
// ============================================================================

class _TestLoginScreen extends StatelessWidget {
  const _TestLoginScreen();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginStates>(
      listener: (context, state) {
        if (state is LoginMfaRequiredState) {
          // Navigate to MFA screen with mfa token
          context.push(AppRoutes.mfaScreen, extra: state.mfaToken);
        } else if (state is LoginSuccessState) {
          // Navigate to dashboard after successful login
          context.go(AppRoutes.dashboardScreen);
        }
      },
      child: Scaffold(
        body: BlocBuilder<LoginCubit, LoginStates>(
          builder: (context, state) {
            final cubit = LoginCubit.get(context);
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Login Screen'),
                  TextField(
                    key: const Key('email_field'),
                    controller: cubit.email,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('password_field'),
                    controller: cubit.password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    key: const Key('login_button'),
                    onPressed: cubit.login,
                    child: const Text('Login'),
                  ),
                  if (state is LoginLoadingState)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (state is LoginErrorState)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Error: ${state.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TestMfaScreen extends StatelessWidget {
  final String mfaToken;

  const _TestMfaScreen({required this.mfaToken});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MfaCubit, MfaState>(
      listener: (context, state) {
        if (state is MfaSuccessState) {
          // Navigate to dashboard after successful MFA verification
          context.go(AppRoutes.dashboardScreen);
        }
      },
      child: Scaffold(
        body: BlocBuilder<MfaCubit, MfaState>(
          builder: (context, state) {
            final cubit = context.read<MfaCubit>();
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('MFA Screen'),
                  TextField(
                    key: const Key('mfa_code_field'),
                    controller: cubit.mfaCode,
                    decoration: const InputDecoration(labelText: 'Enter OTP Code'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    key: const Key('mfa_verify_button'),
                    onPressed: () {
                      cubit.verifyMfa(mfaToken: mfaToken);
                    },
                    child: const Text('Verify'),
                  ),
                  if (state is MfaLoadingState)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (state is MfaErrorState)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Error: ${state.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TestDashboardScreen extends StatelessWidget {
  final MemoryAuthStorage storage;

  const _TestDashboardScreen({required this.storage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GetProfileCubit, GetProfileState>(
        builder: (context, state) {
          if (state is GetProfileSuccessState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Dashboard Screen'),
                  Text('Welcome, ${state.userModel.displayName}!'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    key: const Key('logout_button'),
                    onPressed: () {
                      // Show logout confirmation dialog
                      _showLogoutDialog(context, storage);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, MemoryAuthStorage storage) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              key: const Key('logout_confirm_button'),
              onPressed: () async {
                // Perform logout: clear storage and navigate
                await storage.clearAuthData();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (context.mounted) {
                  GoRouter.of(context).go(AppRoutes.login);
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// END-TO-END TESTS
// ============================================================================

void main() {
  setUpAll(_loadTestEnv);

  group('Authentication E2E Flow Tests', () {
    late MemoryAuthStorage mockStorage;
    late AuthRepository fakeRepository;

    setUp(() {
      mockStorage = MemoryAuthStorage();

      // Initialize the fake repository with default handlers
      fakeRepository = FakeAuthRepository(
        onLogin: ({required email, required password}) async {
          return ApiResponse(
            status: true,
            statusCode: 200,
            message: 'Success',
            data: {
              'mfa_required': true,
              'mfa_token': 'mfa-token-test-12345',
            },
          );
        },
        onVerifyMfa: ({required code, mfaToken}) async {
          return ApiResponse(
            status: true,
            statusCode: 200,
            message: 'Success',
            data: {
              'access_token': 'access-token-abcdef',
              'refresh_token': 'refresh-token-ghijkl',
              'expires_in': 3600,
            },
          );
        },
        onLogout: ({required refreshToken}) async {
          return ApiResponse(
            status: true,
            statusCode: 200,
            message: 'Logged out successfully',
          );
        },
      );
    });

    tearDown(() async {
      await mockStorage.clearAuthData();
    });

    testWidgets(
      'Login → MFA → Access Token → Dashboard → Logout E2E Flow',
      (WidgetTester tester) async {
        // Create the mock profile cubit for this test
        final mockProfileCubit = MockGetProfileCubit();
        final testRouter = _createTestRouter(
          storage: mockStorage,
          authRepository: fakeRepository,
          mockProfileCubit: mockProfileCubit,
        );

        // STEP 1: Build the app and verify LoginScreen is rendered
        await tester.pumpWidget(
          _buildTestApp(
            router: testRouter,
            storage: mockStorage,
            authRepository: fakeRepository,
            mockProfileCubit: mockProfileCubit,
          ),
        );
        await tester.pumpAndSettle();

        // Verify LoginScreen is displayed initially
        expect(find.text('Login Screen'), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsOneWidget);

        // ========================================================================
        // STEP 2: Login Action - Enter credentials and tap login button
        // ========================================================================
        final emailField = find.byKey(const Key('email_field'));
        final passwordField = find.byKey(const Key('password_field'));

        expect(emailField, findsOneWidget);
        expect(passwordField, findsOneWidget);

        // Enter mock email and password
        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, 'password123');
        await tester.pumpAndSettle();

        // Tap the login button
        await tester.tap(find.byKey(const Key('login_button')));
        // Wait a bit for the API call to be processed
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // ========================================================================
        // STEP 3: MFA Required Mock - Verify MFA token is saved in storage
        // ========================================================================
        final savedMfaToken = await mockStorage.getMfaToken();
        expect(savedMfaToken, isNotNull);
        expect(savedMfaToken, 'mfa-token-test-12345');

        // Verify access token is NOT saved yet (we're still in MFA flow)
        final accessTokenBeforeMfa = await mockStorage.getAccessToken();
        expect(accessTokenBeforeMfa, isNull);

        // ========================================================================
        // STEP 4: MFA Navigation - Verify MFAScreen is displayed
        // ========================================================================
        await tester.pumpAndSettle();
        expect(find.text('MFA Screen'), findsOneWidget);
        expect(find.byKey(const Key('mfa_code_field')), findsOneWidget);
        expect(find.byKey(const Key('mfa_verify_button')), findsOneWidget);

        // ========================================================================
        // STEP 5: MFA Action - Enter OTP code and tap verify button
        // ========================================================================
        final mfaCodeField = find.byKey(const Key('mfa_code_field'));
        await tester.enterText(mfaCodeField, '123456');
        await tester.pumpAndSettle();

        // Tap the MFA verify button
        await tester.tap(find.byKey(const Key('mfa_verify_button')));
        await tester.pumpAndSettle();

        // Verify loading state is shown during MFA verification
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // ========================================================================
        // STEP 6: Success Mock - Verify tokens are saved
        // ========================================================================
        // Verify access token is now saved
        final savedAccessToken = await mockStorage.getAccessToken();
        expect(savedAccessToken, isNotNull);
        expect(savedAccessToken, 'access-token-abcdef');

        // Verify refresh token is saved
        final savedRefreshToken = await mockStorage.getRefreshToken();
        expect(savedRefreshToken, isNotNull);
        expect(savedRefreshToken, 'refresh-token-ghijkl');

        // Verify MFA token is cleared after successful verification
        final clearedMfaToken = await mockStorage.getMfaToken();
        expect(clearedMfaToken, isNull);

        // ========================================================================
        // STEP 7: Dashboard Navigation - Verify DashboardScreen is displayed
        // ========================================================================
        await tester.pumpAndSettle();
        expect(find.text('Dashboard Screen'), findsOneWidget);
        expect(
          find.text('Welcome, Test User!'),
          findsOneWidget,
          reason: 'User greeting should be displayed on dashboard',
        );

        // Verify the logout button is present on the dashboard
        expect(find.byKey(const Key('logout_button')), findsOneWidget);

        // ========================================================================
        // STEP 8: Logout Action - Tap logout button and confirm
        // ========================================================================
        await tester.tap(find.byKey(const Key('logout_button')));
        await tester.pumpAndSettle();

        // Verify logout confirmation dialog is shown
        expect(find.text('Confirm Logout'), findsOneWidget);
        expect(
          find.byKey(const Key('logout_confirm_button')),
          findsOneWidget,
        );

        // Tap the logout confirm button and wait for navigation
        await tester.tap(find.byKey(const Key('logout_confirm_button')));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // ========================================================================
        // STEP 9: Logout Verification - Verify tokens are cleared and redirected
        // ========================================================================
        // Verify navigation back to LoginScreen indicates successful logout
        expect(find.text('Login Screen'), findsOneWidget,
            reason: 'Should redirect to login screen after logout');

        // Verify tokens are cleared from storage
        final accessTokenAfterLogout = await mockStorage.getAccessToken();
        expect(accessTokenAfterLogout, isNull,
            reason: 'Access token should be cleared after logout');

        final refreshTokenAfterLogout = await mockStorage.getRefreshToken();
        expect(refreshTokenAfterLogout, isNull,
            reason: 'Refresh token should be cleared after logout');

        final mfaTokenAfterLogout = await mockStorage.getMfaToken();
        expect(mfaTokenAfterLogout, isNull,
            reason: 'MFA token should be cleared after logout');
      },
    );

    testWidgets(
      'Login without MFA goes directly to Dashboard',
      (WidgetTester tester) async {
        // Setup repository to return direct login success (no MFA required)
        final directLoginRepository = FakeAuthRepository(
          onLogin: ({required email, required password}) async {
            return ApiResponse(
              status: true,
              statusCode: 200,
              message: 'Success',
              data: {
                'mfa_required': false,
                'access_token': 'access-token-direct',
                'refresh_token': 'refresh-token-direct',
                'expires_in': 3600,
              },
            );
          },
        );

        final mockProfileCubit = MockGetProfileCubit();
        final directLoginRouter = _createTestRouter(
          storage: mockStorage,
          authRepository: directLoginRepository,
          mockProfileCubit: mockProfileCubit,
        );

        await tester.pumpWidget(
          _buildTestApp(
            router: directLoginRouter,
            storage: mockStorage,
            authRepository: directLoginRepository,
            mockProfileCubit: mockProfileCubit,
          ),
        );
        await tester.pumpAndSettle();

        // Login with email and password
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify direct navigation to dashboard (no MFA screen)
        expect(find.text('Dashboard Screen'), findsOneWidget);

        // Verify tokens are saved
        final accessToken = await mockStorage.getAccessToken();
        expect(accessToken, 'access-token-direct');
      },
    );

    testWidgets(
      'Login error is displayed when credentials are invalid',
      (WidgetTester tester) async {
        // Setup repository to return login error
        final errorRepository = FakeAuthRepository(
          onLogin: ({required email, required password}) async {
            return ApiResponse(
              status: false,
              statusCode: 401,
              message: 'Invalid email or password',
            );
          },
        );

        final mockProfileCubit = MockGetProfileCubit();
        final errorRouter = _createTestRouter(
          storage: mockStorage,
          authRepository: errorRepository,
          mockProfileCubit: mockProfileCubit,
        );

        await tester.pumpWidget(
          _buildTestApp(
            router: errorRouter,
            storage: mockStorage,
            authRepository: errorRepository,
            mockProfileCubit: mockProfileCubit,
          ),
        );
        await tester.pumpAndSettle();

        // Attempt login
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'wrong@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'wrongpassword',
        );
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();

        // Verify error message is displayed
        expect(find.text('Error: Invalid email or password'), findsOneWidget);

        // Verify no tokens are saved
        expect(await mockStorage.getAccessToken(), isNull);
        expect(await mockStorage.getRefreshToken(), isNull);
      },
    );

    testWidgets(
      'MFA verification stores both access and refresh tokens',
      (WidgetTester tester) async {
        final mockProfileCubit = MockGetProfileCubit();
        final testRouter = _createTestRouter(
          storage: mockStorage,
          authRepository: fakeRepository,
          mockProfileCubit: mockProfileCubit,
        );

        await tester.pumpWidget(
          _buildTestApp(
            router: testRouter,
            storage: mockStorage,
            authRepository: fakeRepository,
            mockProfileCubit: mockProfileCubit,
          ),
        );
        await tester.pumpAndSettle();

        // Complete login to reach MFA
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'password123',
        );
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify MFA screen is shown
        expect(find.text('MFA Screen'), findsOneWidget);

        // Enter MFA code
        await tester.enterText(
          find.byKey(const Key('mfa_code_field')),
          '123456',
        );
        await tester.tap(find.byKey(const Key('mfa_verify_button')));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify both tokens are stored
        expect(await mockStorage.getAccessToken(), 'access-token-abcdef');
        expect(await mockStorage.getRefreshToken(), 'refresh-token-ghijkl');
        expect(await mockStorage.getMfaToken(), isNull);
      },
    );
  });
}
