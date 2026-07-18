// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/features/settings/cubits/mfa_settings/mfa_settings_state.dart';
import 'package:spora_app/features/settings/data/model/mfa_setup_model.dart';
import 'package:spora_app/features/settings/data/repo/mfa_settings_repo.dart';

class MfaSettingsCubit extends Cubit<MfaSettingsState> {
  MfaSettingsCubit() : super(MfaSettingsInitial());

  static MfaSettingsCubit get(context) => BlocProvider.of(context);

  final MfaSettingsRepo repo = MfaSettingsRepo();
  MfaSetupModel? currentSetup;

  final setupCodeController = TextEditingController();
  final disablePasswordController = TextEditingController();
  final disableCodeController = TextEditingController();

  final setupFormKey = GlobalKey<FormState>();
  final disableFormKey = GlobalKey<FormState>();

  Future<void> startSetup() async {
    emit(MfaSettingsLoading());

    final result = await repo.setupMfa();

    if (result.status && result.data != null) {
      final setupData = repo.parseSetupData(result.data);
      if (setupData == null) {
        emit(MfaSettingsError('Invalid setup response'));
        return;
      }
      currentSetup = setupData;
      emit(MfaSetupReady(setupData));
    } else {
      emit(MfaSettingsError(result.message));
    }
  }

  Future<void> confirmSetup() async {
    if (setupFormKey.currentState?.validate() != true) return;

    emit(MfaSettingsLoading());

    final result = await repo.verifySetup(code: setupCodeController.text);

    if (result.status) {
      setupCodeController.clear();
      currentSetup = null;
      emit(MfaSettingsSuccess('MFA enabled successfully'));
    } else {
      emit(MfaSettingsError(result.message));
      if (currentSetup != null) {
        emit(MfaSetupReady(currentSetup!));
      }
    }
  }

  Future<void> disableMfa() async {
    if (disableFormKey.currentState?.validate() != true) return;

    emit(MfaSettingsLoading());

    final result = await repo.disableMfa(
      password: disablePasswordController.text,
      code: disableCodeController.text,
    );

    if (result.status) {
      disablePasswordController.clear();
      disableCodeController.clear();
      emit(
        MfaSettingsSuccess(
          'MFA disabled successfully. Please login again.',
          requireRelogin: true,
        ),
      );
    } else {
      emit(MfaSettingsError(result.message));
    }
  }

  void resetToInitial() {
    currentSetup = null;
    emit(MfaSettingsInitial());
  }

  @override
  Future<void> close() {
    setupCodeController.dispose();
    disablePasswordController.dispose();
    disableCodeController.dispose();
    return super.close();
  }
}
