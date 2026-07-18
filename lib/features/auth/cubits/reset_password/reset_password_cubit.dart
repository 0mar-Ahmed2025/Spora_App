import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/features/auth/cubits/reset_password/reset_password_state.dart';
import 'package:spora_app/features/auth/data/repo/auth_repository.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit({AuthRepository? repo})
    : repo = repo ?? AuthRepository(),
      super(ResetPasswordInitial());

  final AuthRepository repo;
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> submitResetRequest() async {
    if (formKey.currentState?.validate() != true) return;

    emit(ResetPasswordLoading());

    try {
      final result = await repo.forgotPassword(
        email: emailController.text.trim(),
      );

      if (!result.status) {
        emit(ResetPasswordError(result.message));
        return;
      }

      emit(
        ResetPasswordSuccess(
          result.message.isNotEmpty
              ? result.message
              : 'Password reset instructions sent to your email.',
        ),
      );
    } catch (e) {
      emit(ResetPasswordError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    return super.close();
  }
}
