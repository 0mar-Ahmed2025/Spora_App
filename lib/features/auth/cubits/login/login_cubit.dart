import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spora_app/core/cache/auth_storage.dart';

import 'package:spora_app/core/cache/cache_helper.dart';

import 'package:spora_app/features/auth/cubits/login/login_state.dart';

import 'package:spora_app/features/auth/data/models/auth_response_model.dart';

import 'package:spora_app/features/auth/data/repo/auth_repository.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit({AuthRepository? repo, AuthStorage? storage})
    : repo = repo ?? AuthRepository(),

      _storage = storage ?? CacheHelper(),

      super(LoginInitialState());

  static LoginCubit get(context) => BlocProvider.of(context);

  final AuthRepository repo;

  final AuthStorage _storage;

  var email = TextEditingController();

  var password = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool passwordSecure = true;

  void changePasswordVisibility() {
    passwordSecure = !passwordSecure;

    emit(ChangePasswordVisibilityState());
  }

  Future<void> login() async {
    if (formKey.currentState?.validate() == false) return;

    emit(LoginLoadingState());

    try {
      var result = await repo.login(email: email.text, password: password.text);

      if (!result.status || result.data == null || result.data is! Map) {
        emit(LoginErrorState(error: result.message));

        return;
      }

      var authModel = AuthResponseModel.fromJson(
        Map<String, dynamic>.from(result.data as Map),
      );

      if (authModel.mfaRequired == true) {
        final mfaToken = authModel.mfaToken?.trim() ?? '';

        if (mfaToken.isEmpty) {
          emit(
            LoginErrorState(
              error: 'MFA Token is missing from server response.',
            ),
          );

          return;
        }

        await _storage.saveMfaToken(mfaToken);

        emit(LoginMfaRequiredState(mfaToken: mfaToken));

        return;
      }

      final accessToken = authModel.accessToken?.trim() ?? '';

      final refreshToken = authModel.refreshToken?.trim() ?? '';

      if (accessToken.isEmpty) {
        emit(
          LoginErrorState(
            error: 'Login succeeded but access token is missing.',
          ),
        );

        return;
      }

      await _storage.saveTokens(accessToken, refreshToken: refreshToken);

      await _storage.clearMfaToken();

      emit(LoginSuccessState(authModel: authModel));
    } catch (e) {
      emit(LoginErrorState(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    email.dispose();

    password.dispose();

    return super.close();
  }
}
