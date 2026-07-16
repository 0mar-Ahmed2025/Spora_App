// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/core/cache/cache_helper.dart';
import 'package:spora_app/features/auth/cubits/login/login_state.dart';
import 'package:spora_app/features/auth/data/models/auth_response_model.dart';
import 'package:spora_app/features/auth/data/repo/auth_repository.dart';

class _CacheHelperImpl extends CacheHelper {}

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginInitialState());
  static LoginCubit get(context) => BlocProvider.of(context);

  final AuthRepository repo = AuthRepository();
  final _cacheHelper = _CacheHelperImpl();

  var email = TextEditingController();
  var password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool passwordSecure = true;

  void changePasswordVisibility() {
    passwordSecure = !passwordSecure;
    emit(ChangePasswordVisibilityState());
  }

  login() async {
    if (formKey.currentState?.validate() == false) return;
    emit(LoginLoadingState());

    var result = await repo.login(email: email.text, password: password.text);

    if (result.status) {
      var authModel = AuthResponseModel.fromJson(result.data);

      if (authModel.mfaRequired == true) {
        if (authModel.mfaToken != null) {
          await _cacheHelper.saveMfaToken(authModel.mfaToken!);
          emit(LoginMfaRequiredState(mfaToken: authModel.mfaToken!));
        } else {
          emit(
            LoginErrorState(
              error: "MFA Token is missing from server response.",
            ),
          );
        }
      } else {
        await _cacheHelper.saveTokens(
          authModel.accessToken,
          refreshToken: authModel.refreshToken ?? '',
        );
        emit(LoginSuccessState(authModel: authModel));
      }
    } else {
      emit(LoginErrorState(error: result.message));
    }
  }



  




}
