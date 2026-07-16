// ignore_for_file: strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/features/auth/cubits/register/register_state.dart';
import 'package:spora_app/features/auth/data/repo/auth_repository.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());
  static RegisterCubit get(context) => BlocProvider.of(context);

  AuthRepository repo = AuthRepository();
  var username = TextEditingController();
  var password = TextEditingController();
  var confirmPassword = TextEditingController();

  var email = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool passwordSecure = true;
  bool confirmPasswordSecure = true;
  void changePasswordVisibility() {
    passwordSecure = !passwordSecure;
    emit(ChangePasswordVisibilityState());
  }

  void confirmPasswordVisibility() {
    confirmPasswordSecure = !confirmPasswordSecure;
    emit(ConfirmPasswordVisibilityState());
  }

  register() async {
    if (formKey.currentState?.validate() == false) return;
    emit(RegisterLoading());

    try {
      final result = await repo.register(
        name: username.text,
        email: email.text,
        password: password.text,
      );

      emit(RegisterSuccess(result.toString()));
    } catch (e) {
      emit(RegisterFailure(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
