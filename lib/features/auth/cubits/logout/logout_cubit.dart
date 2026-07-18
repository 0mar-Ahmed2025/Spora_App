import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/core/cache/auth_storage.dart';
import 'package:spora_app/core/cache/cache_helper.dart';
import 'package:spora_app/features/auth/cubits/logout/logout_state.dart';
import 'package:spora_app/features/auth/data/repo/auth_repository.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit({
    AuthRepository? authRepository,
    AuthStorage? storage,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _storage = storage ?? CacheHelper(),
        super(LogoutInitial());

  final AuthRepository _authRepository;
  final AuthStorage _storage;

  Future<void> logout() async {
    emit(LogoutLoading());

    try {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _authRepository.logout(refreshToken: refreshToken);
        } catch (_) {}
      }

      await _storage.clearAuthData();
      emit(LogoutSuccess());
    } catch (e) {
      emit(LogoutFailure(e.toString()));
    }
  }
}
