import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/features/settings/data/repo/change_password_repo.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(ChangePasswordInitial());

  final ChangePasswordRepo repo = ChangePasswordRepo();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController mfaCode = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    emit(ChangePasswordLoading());

    try {
      var result = await repo.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
        code: mfaCode.text,
      );

      if (result.status) {
        emit(ChangePasswordSuccess());
      } else {
        emit(ChangePasswordError(result.message.toString()));
      }
    } catch (e) {
      emit(ChangePasswordError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
