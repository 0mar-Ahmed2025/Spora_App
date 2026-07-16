import 'package:spora_app/features/auth/data/models/auth_response_model.dart';

abstract class LoginStates {}

class LoginInitialState extends LoginStates {}

class ChangePasswordVisibilityState extends LoginStates {}

class LoginLoadingState extends LoginStates {}

class LoginSuccessState extends LoginStates {
  final AuthResponseModel authModel;
  LoginSuccessState({required this.authModel});
}

class LoginMfaRequiredState extends LoginStates {
  final String mfaToken;
  LoginMfaRequiredState({required this.mfaToken});
}

class LoginErrorState extends LoginStates {
  final String error;
  LoginErrorState({required this.error});
}
