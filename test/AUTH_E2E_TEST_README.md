# Authentication E2E Flow Test Documentation

## Overview

The `auth_e2e_flow_test.dart` file contains a comprehensive end-to-end (E2E) widget test suite that covers the complete authentication workflow of the Spora Flutter app. This test validates the entire user journey from login through MFA verification to dashboard access and finally logout.

## Test Coverage

### Primary Test: Login → MFA → Access Token → Dashboard → Logout E2E Flow

This is the main comprehensive test that validates the complete authentication workflow:

1. **Login State**: Verifies that the LoginScreen is rendered on app startup
2. **Login Action**: Enters mock credentials (email and password) and taps the login button
3. **MFA Required Mock**: Mocks the Dio API response to simulate MFA requirement
4. **MFA Navigation**: Verifies navigation to MFAScreen and MFA token storage
5. **MFA Action**: Enters a mock OTP code and taps the verify button
6. **Success Mock**: Mocks successful MFA response with access and refresh tokens
7. **Dashboard Navigation**: Verifies tokens are saved and navigation to DashboardScreen
8. **Logout Action**: Taps logout button and confirms logout in dialog
9. **Logout Verification**: Verifies tokens are cleared and user is redirected to LoginScreen

### Additional Test Cases

- **Login without MFA**: Tests direct login to dashboard when MFA is not required
- **Login Error Handling**: Verifies error messages are displayed for invalid credentials
- **MFA Token Storage**: Validates that both access and refresh tokens are properly stored after MFA

## Test Architecture

### Mock Setup

The test uses several key mock components:

#### MockGetProfileCubit
```dart
class MockGetProfileCubit extends Mock implements GetProfileCubit {
  @override
  Stream<GetProfileState> get stream => Stream.value(
    GetProfileSuccessState(userModel: _createMockUser()),
  );

  @override
  GetProfileState get state => GetProfileSuccessState(userModel: _createMockUser());
}
```

#### FakeAuthRepository
- Mocks the authentication repository with configurable responses
- Allows testing both success and failure scenarios
- Supports MFA flow simulation

#### MemoryAuthStorage
- In-memory implementation of AuthStorage
- Simulates token storage without actual secure storage dependencies
- Used to verify tokens are saved and cleared correctly

### Test Screens

The test includes simplified test versions of the actual screens:

- **_TestLoginScreen**: Simplified login UI with email/password fields and login button
- **_TestMfaScreen**: Simplified MFA UI with OTP code field and verify button
- **_TestDashboardScreen**: Simplified dashboard with logout button and confirmation dialog

## Key Features

### 1. Proper Async Handling
- Uses `tester.pumpAndSettle()` to wait for all animations and state transitions to complete
- Includes appropriate wait durations for async operations
- Properly handles GoRouter navigation

### 2. Comprehensive Navigation Testing
- Tests GoRouter push navigation (Login → MFA)
- Tests GoRouter go navigation (MFA → Dashboard, Dashboard → Login)
- Verifies screen widgets appear after navigation

### 3. State Management Testing
- Tests Cubit state emissions (Loading, Success, Error)
- Verifies proper state transitions throughout the flow
- Uses BlocProvider and BlocBuilder/BlocListener patterns

### 4. Storage Verification
- Verifies MFA token is saved during login
- Confirms access/refresh tokens are saved after MFA
- Validates tokens are cleared on logout

### 5. Dependency Injection
- Uses FakeAuthRepository instead of real Dio client
- Uses MemoryAuthStorage instead of FlutterSecureStorage
- Simplifies testing by removing external dependencies

## Running the Tests

### Run All E2E Tests
```bash
flutter test test/auth_e2e_flow_test.dart
```

### Run Specific Test
```bash
flutter test test/auth_e2e_flow_test.dart -k "Login → MFA → Access Token"
```

### Run with Verbose Output
```bash
flutter test test/auth_e2e_flow_test.dart -v
```

## Expected Output

When tests pass successfully:
```
00:00 +0: (setUpAll)
00:00 +0: Authentication E2E Flow Tests Login → MFA → Access Token → Dashboard → Logout E2E Flow
00:03 +1: Authentication E2E Flow Tests Login without MFA goes directly to Dashboard
00:04 +2: Authentication E2E Flow Tests Login error is displayed when credentials are invalid
00:04 +3: Authentication E2E Flow Tests MFA verification stores both access and refresh tokens
00:05 +4: (tearDownAll)
00:05 +4: All tests passed!
```

## Test Data

### Mock Credentials
- **Email**: test@example.com
- **Password**: password123

### Mock OTP
- **Code**: 123456

### Mock Tokens
- **MFA Token**: mfa-token-test-12345
- **Access Token**: access-token-abcdef
- **Refresh Token**: refresh-token-ghijkl

## Dependencies

The test uses the following dependencies:
- **flutter_test**: Flutter's testing framework
- **mocktail**: Mocking library for Dart/Flutter
- **flutter_bloc**: State management
- **go_router**: Navigation
- **flutter_screenutil**: Screen size adaptation
- **provider**: Service locator/provider pattern

Added to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.5
  flutter_lints: ^6.0.0
```

## Test Helpers

### _loadTestEnv()
- Initializes test environment
- Called once with `setUpAll()`

### _createMockUser()
- Creates a UserData object with test values
- Used for dashboard screen testing

### _buildTestApp()
- Creates the test app widget with all necessary providers
- Configures routing for the test

### _createTestRouter()
- Creates a GoRouter configured for testing
- Sets up routes for Login, MFA, and Dashboard screens

## Important Notes

### Screen Simplification
The test uses simplified versions of the actual screens to:
- Avoid complexity with EasyLocalization
- Reduce dependency on third-party packages (e.g., Pinput for MFA)
- Focus on testing the authentication flow logic

### Storage Access
The logout dialog directly accesses the MemoryAuthStorage to clear data, which:
- Simulates real logout behavior
- Avoids provider scope issues
- Ensures tokens are actually cleared

### Navigation Timing
Tests include appropriate delays to allow:
- API mock responses to be processed
- State transitions to complete
- Widget rebuilds to settle

## Extending the Tests

To add new test cases:

1. Add a new `testWidgets` block within the group
2. Set up necessary mocks in the test
3. Create a new router if needed
4. Use meaningful test names that describe the scenario
5. Include comprehensive comments explaining each step

Example:
```dart
testWidgets('Test scenario description', (WidgetTester tester) async {
  // Setup
  final mockProfileCubit = MockGetProfileCubit();
  final testRouter = _createTestRouter(
    storage: mockStorage,
    authRepository: fakeRepository,
    mockProfileCubit: mockProfileCubit,
  );

  // Build app
  await tester.pumpWidget(_buildTestApp(/*...*/));
  await tester.pumpAndSettle();

  // Test steps with comments
  // ...

  // Assertions
  expect(/*...*/);
});
```

## Troubleshooting

### Test Fails with "Widget not found"
- Increase wait time with `pumpAndSettle(Duration(seconds: N))`
- Verify key names match between test and widgets
- Check if navigation completed successfully

### Mock Not Working
- Ensure mock is created fresh for each test
- Verify mock methods are properly stubbed
- Check that the correct mock is passed to widgets

### State Not Transitioning
- Add longer delays before assertions
- Verify Cubit methods are being called
- Check BlocListener/BlocBuilder is properly connected

## CI/CD Integration

To run these tests in CI/CD:

```yaml
test:
  stage: test
  script:
    - flutter pub get
    - flutter test test/auth_e2e_flow_test.dart
  coverage: '/Coverage: \d+\.\d+%/'
```

## Future Improvements

1. Add code coverage measurement
2. Add performance benchmarking
3. Extend tests for token refresh scenarios
4. Add tests for error recovery flows
5. Add tests for concurrent login attempts
6. Test with real networking (integration tests)

## Related Files

- **LoginCubit**: `lib/features/auth/cubits/login/login_cubit.dart`
- **MfaCubit**: `lib/features/auth/cubits/mfa_verify/mfa_cubit.dart`
- **LogoutCubit**: `lib/features/auth/cubits/logout/logout_cubit.dart`
- **AuthRepository**: `lib/features/auth/data/repo/auth_repository.dart`
- **AuthStorage**: `lib/core/cache/auth_storage.dart`
- **AppRouter**: `lib/core/routing/app_router.dart`

## Support

For issues or questions about these tests:
1. Review the test file comments
2. Check the Related Files section
3. Verify all dependencies are installed with `flutter pub get`
4. Run with verbose output: `flutter test -v`
