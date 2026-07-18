import 'package:spora_app/features/settings/data/model/mfa_setup_model.dart';

abstract class MfaSettingsState {}

class MfaSettingsInitial extends MfaSettingsState {}

class MfaSettingsLoading extends MfaSettingsState {}

class MfaSetupReady extends MfaSettingsState {
  final MfaSetupModel setupData;

  MfaSetupReady(this.setupData);
}

class MfaSettingsSuccess extends MfaSettingsState {
  final String message;
  final bool requireRelogin;

  MfaSettingsSuccess(this.message, {this.requireRelogin = false});
}

class MfaSettingsError extends MfaSettingsState {
  final String message;

  MfaSettingsError(this.message);
}
