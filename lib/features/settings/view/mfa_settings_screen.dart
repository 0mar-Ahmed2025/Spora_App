import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:spora_app/core/cache/cache_helper.dart';
import 'package:spora_app/core/helper/app_pop_up.dart';
import 'package:spora_app/core/helper/app_validator.dart';
import 'package:spora_app/core/routing/app_routes.dart';
import 'package:spora_app/core/shared/custom_button.dart';
import 'package:spora_app/core/shared/custom_textfield.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/features/settings/cubits/mfa_settings/mfa_settings_cubit.dart';
import 'package:spora_app/features/settings/cubits/mfa_settings/mfa_settings_state.dart';
import 'package:spora_app/features/settings/data/model/mfa_setup_model.dart';

class MfaSettingsScreen extends StatelessWidget {
  const MfaSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MfaSettingsCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('MFA Settings'), centerTitle: true),
        body: BlocConsumer<MfaSettingsCubit, MfaSettingsState>(
          listener: (context, state) async {
            if (state is MfaSettingsSuccess) {
              SnackBarPopUp().show(
                context: context,
                message: state.message,
                state: PopUpState.success,
              );

              if (state.requireRelogin) {
                await CacheHelper().clearAuthData();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
                return;
              }

              context.read<MfaSettingsCubit>().resetToInitial();
            } else if (state is MfaSettingsError) {
              SnackBarPopUp().show(
                context: context,
                message: state.message,
                state: PopUpState.error,
              );
            }
          },
          builder: (context, state) {
            final cubit = MfaSettingsCubit.get(context);

            if (state is MfaSettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MfaSetupReady) {
              return SetupConfirmView(setupData: state.setupData, cubit: cubit);
            }

            return MfaHomeView(cubit: cubit);
          },
        ),
      ),
    );
  }
}

class MfaHomeView extends StatelessWidget {
  const MfaHomeView({required this.cubit});

  final MfaSettingsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Two-Factor Authentication',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Protect your account with a TOTP code from an authenticator app.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 28.h),
          AppButton(text: 'Enable MFA', onPressed: cubit.startSetup),
          SizedBox(height: 32.h),
          const Divider(),
          SizedBox(height: 16.h),
          Text(
            'Disable MFA',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Enter your password and current authenticator code.',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.h),
          Form(
            key: cubit.disableFormKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: cubit.disablePasswordController,
                  labelText: 'Password',
                  obscureText: true,
                  validator: AppValidator.validateRequired,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: cubit.disableCodeController,
                  labelText: 'MFA Code',
                  keyboardType: TextInputType.number,
                  validator: AppValidator.validateRequired,
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: cubit.disableMfa,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      'Disable MFA',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SetupConfirmView extends StatelessWidget {
  const SetupConfirmView({required this.setupData, required this.cubit});

  final MfaSetupModel setupData;
  final MfaSettingsCubit cubit;

  @override
  Widget build(BuildContext context) {
    Uint8List? qrBytes;
    try {
      if (setupData.qrBase64.isNotEmpty) {
        qrBytes = base64Decode(setupData.qrBase64);
      }
    } catch (_) {
      qrBytes = null;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Form(
        key: cubit.setupFormKey,
        child: Column(
          children: [
            Text(
              'Scan this QR code',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Use Google Authenticator or any TOTP app, then enter the 6-digit code.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            if (qrBytes != null)
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.enabledBorderSideColor),
                ),
                child: Image.memory(
                  qrBytes,
                  width: 200.w,
                  height: 200.w,
                  fit: BoxFit.contain,
                ),
              )
            else
              Text(
                'QR image not available. Use the secret below.',
                style: TextStyle(fontSize: 13.sp, color: Colors.orange),
              ),
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Secret key',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      setupData.secretBase32,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: setupData.secretBase32),
                      );
                      if (context.mounted) {
                        SnackBarPopUp().show(
                          context: context,
                          message: 'Secret copied',
                          state: PopUpState.success,
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 20),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            CustomTextField(
              controller: cubit.setupCodeController,
              labelText: '6-digit code',
              keyboardType: TextInputType.number,
              validator: AppValidator.validateRequired,
            ),
            SizedBox(height: 24.h),
            AppButton(text: 'Confirm & Enable', onPressed: cubit.confirmSetup),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: cubit.resetToInitial,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
