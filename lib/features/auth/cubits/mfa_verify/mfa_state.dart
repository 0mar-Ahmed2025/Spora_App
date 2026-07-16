import 'package:spora_app/features/auth/data/models/auth_response_model.dart';

abstract class MfaState {}

class MfaInitialState extends MfaState {}


class MfaLoadingState extends MfaState {}

class MfaSuccessState extends MfaState {
  final AuthResponseModel authModel;
  MfaSuccessState({required this.authModel});
}


class MfaErrorState extends MfaState {
  final String error;
  MfaErrorState({required this.error});
}
