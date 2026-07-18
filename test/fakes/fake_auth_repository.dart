import 'package:spora_app/core/network/api_response.dart';
import 'package:spora_app/features/auth/data/repo/auth_repository.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({
    this.onLogin,
    this.onVerifyMfa,
    this.onResendMfa,
    this.onForgotPassword,
    this.onLogout,
  });

  final Future<ApiResponse> Function({
    required String email,
    required String password,
  })?
  onLogin;

  final Future<ApiResponse> Function({
    required String code,
    String? mfaToken,
  })?
  onVerifyMfa;

  final Future<ApiResponse> Function({required String mfaToken})? onResendMfa;

  final Future<ApiResponse> Function({required String email})? onForgotPassword;

  final Future<ApiResponse> Function({required String refreshToken})? onLogout;

  @override
  Future<ApiResponse> login({
    required String email,
    required String password,
  }) {
    assert(onLogin != null, 'onLogin handler is required');
    return onLogin!(email: email, password: password);
  }

  @override
  Future<ApiResponse> verifyMfa({
    required String code,
    String? mfaToken,
  }) {
    assert(onVerifyMfa != null, 'onVerifyMfa handler is required');
    return onVerifyMfa!(code: code, mfaToken: mfaToken);
  }

  @override
  Future<ApiResponse> resendMfa({required String mfaToken}) {
    assert(onResendMfa != null, 'onResendMfa handler is required');
    return onResendMfa!(mfaToken: mfaToken);
  }

  @override
  Future<ApiResponse> forgotPassword({required String email}) {
    assert(onForgotPassword != null, 'onForgotPassword handler is required');
    return onForgotPassword!(email: email);
  }

  @override
  Future<ApiResponse> logout({required String refreshToken}) {
    assert(onLogout != null, 'onLogout handler is required');
    return onLogout!(refreshToken: refreshToken);
  }
}
