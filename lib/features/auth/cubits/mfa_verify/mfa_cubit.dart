// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/core/cache/cache_helper.dart';
import 'package:spora_app/features/auth/cubits/mfa_verify/mfa_state.dart';
import 'package:spora_app/features/auth/data/models/auth_response_model.dart';
import 'package:spora_app/features/auth/data/repo/auth_repository.dart';

class _CacheHelperImpl extends CacheHelper {}

class MfaCubit extends Cubit<MfaState> {
  MfaCubit() : super(MfaInitialState());
  static MfaCubit get(context) => BlocProvider.of(context);

  final AuthRepository repo = AuthRepository();
  final _cacheHelper = _CacheHelperImpl();

  var mfaCode = TextEditingController();
  final formKey = GlobalKey<FormState>();

  verifyMfa({required String mfaToken}) async {
    if (formKey.currentState?.validate() == false) return;
    emit(MfaLoadingState());

    var result = await repo.verifyMfa(code: mfaCode.text, mfaToken: mfaToken);

    if (result.status) {
      var authModel = AuthResponseModel.fromJson(result.data);
      await _cacheHelper.saveTokens(
        authModel.accessToken,
        refreshToken: authModel.refreshToken!,
      );
      await _cacheHelper.saveTokenCode(mfaCode.text);
      emit(MfaSuccessState(authModel: authModel));
    } else {
      emit(MfaErrorState(error: result.message));
    }
  }
}
