import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/core/cache/cache_helper.dart';
import 'package:spora_app/features/auth/cubits/logout/logout_state.dart';
import 'package:spora_app/features/auth/data/repo/auth_repository.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutInitial());

  final AuthRepository _authRepository = AuthRepository();
  final CacheHelper _cacheHelper = CacheHelper();

  Future<void> logout() async {
    emit(LogoutLoading());

    try {
      final refreshToken = await _cacheHelper.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await _cacheHelper.clearAuthData();
        emit(LogoutSuccess());
        return;
      }

      final response = await _authRepository.logout(refreshToken: refreshToken);

      await _cacheHelper.clearAuthData();

      if (response.status) {
        emit(LogoutSuccess());
      } else {
        emit(LogoutFailure(response.message));
      }
    } catch (e) {
      await _cacheHelper.clearAuthData();
      emit(LogoutFailure(e.toString()));
    }
  }
}
