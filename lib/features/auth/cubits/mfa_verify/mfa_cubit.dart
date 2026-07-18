import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spora_app/core/cache/auth_storage.dart';

import 'package:spora_app/core/cache/cache_helper.dart';

import 'package:spora_app/core/config/app_config.dart';

import 'package:spora_app/features/auth/cubits/mfa_verify/mfa_state.dart';

import 'package:spora_app/features/auth/data/models/auth_response_model.dart';

import 'package:spora_app/features/auth/data/repo/auth_repository.dart';



class MfaCubit extends Cubit<MfaState> {

  MfaCubit({

    AuthRepository? repo,

    AuthStorage? storage,

  })  : repo = repo ?? AuthRepository(),

        _storage = storage ?? CacheHelper(),

        super(MfaInitialState());



  final AuthRepository repo;

  final AuthStorage _storage;

  final mfaCode = TextEditingController();

  final formKey = GlobalKey<FormState>();



  Future<void> verifyMfa({required String mfaToken}) async {

    if (formKey.currentState?.validate() == false) return;

    emit(MfaLoadingState());



    try {

      var token = mfaToken.trim();

      if (token.isEmpty) {

        token = (await _storage.getMfaToken())?.trim() ?? '';

      }



      if (token.isEmpty) {

        emit(MfaErrorState(error: 'MFA session expired. Please login again.'));

        return;

      }



      var result = await repo.verifyMfa(code: mfaCode.text, mfaToken: token);



      if (!result.status || result.data == null || result.data is! Map) {

        emit(MfaErrorState(error: result.message));

        return;

      }



      var authModel = AuthResponseModel.fromJson(

        Map<String, dynamic>.from(result.data as Map),

      );



      final accessToken = authModel.accessToken?.trim() ?? '';

      final refreshToken = authModel.refreshToken?.trim() ?? '';



      if (accessToken.isEmpty) {

        emit(

          MfaErrorState(

            error: 'MFA succeeded but access token is missing.',

          ),

        );

        return;

      }



      await _storage.saveTokens(

        accessToken,

        refreshToken: refreshToken,

      );

      await _storage.clearMfaToken();

      mfaCode.clear();

      emit(MfaSuccessState(authModel: authModel));

    } catch (e) {

      emit(MfaErrorState(error: e.toString()));

    }

  }



  Future<void> resendMfa({required String mfaToken}) async {

    if (!AppConfig.isMfaResendEnabled) {

      emit(

        MfaResendErrorState(

          error: 'Resend code is not enabled yet. Please contact support.',

        ),

      );

      return;

    }



    emit(MfaResendLoadingState());



    try {

      var token = mfaToken.trim();

      if (token.isEmpty) {

        token = (await _storage.getMfaToken())?.trim() ?? '';

      }



      if (token.isEmpty) {

        emit(MfaResendErrorState(error: 'MFA session expired. Please login again.'));

        return;

      }



      final result = await repo.resendMfa(mfaToken: token);



      if (!result.status) {

        emit(MfaResendErrorState(error: result.message));

        return;

      }



      emit(MfaResendSuccessState());

    } catch (e) {

      emit(MfaResendErrorState(error: e.toString()));

    }

  }



  @override

  Future<void> close() {

    mfaCode.dispose();

    return super.close();

  }

}


