import 'dart:async';



import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

import 'package:pinput/pinput.dart';

import 'package:spora_app/core/config/app_config.dart';

import 'package:spora_app/core/helper/app_pop_up.dart';

import 'package:spora_app/core/helper/app_validator.dart';

import 'package:spora_app/core/routing/app_routes.dart';

import 'package:spora_app/core/shared/custom_button.dart';

import 'package:spora_app/core/theme/app_colors.dart';

import 'package:spora_app/features/auth/cubits/mfa_verify/mfa_cubit.dart';

import 'package:spora_app/features/auth/cubits/mfa_verify/mfa_state.dart';

import 'package:spora_app/generated/locale_keys.g.dart';



class MfaVerificationView extends StatefulWidget {

  const MfaVerificationView({super.key});



  @override

  State<MfaVerificationView> createState() => _MfaVerificationViewState();

}



class _MfaVerificationViewState extends State<MfaVerificationView> {

  static const _resendCooldownSeconds = 60;



  Timer? _countdownTimer;

  int _secondsRemaining = _resendCooldownSeconds;



  @override

  void initState() {

    super.initState();

    _startCountdown();

  }



  @override

  void dispose() {

    _countdownTimer?.cancel();

    super.dispose();

  }



  void _startCountdown() {

    _countdownTimer?.cancel();

    setState(() => _secondsRemaining = _resendCooldownSeconds);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {

      if (_secondsRemaining <= 1) {

        timer.cancel();

        setState(() => _secondsRemaining = 0);

        return;

      }

      setState(() => _secondsRemaining -= 1);

    });

  }



  @override

  Widget build(BuildContext context) {

    final token = GoRouterState.of(context).extra as String?;



    final defaultPinTheme = PinTheme(

      width: 64.w,

      height: 64.h,

      textStyle: TextStyle(

        fontSize: 22.sp,

        fontWeight: FontWeight.bold,

        color: AppColors.textPrimary,

      ),

      decoration: BoxDecoration(

        color: AppColors.background,

        borderRadius: BorderRadius.circular(16.r),

        border: Border.all(color: AppColors.textSecondary, width: 1),

      ),

    );



    final focusedPinTheme = defaultPinTheme.copyWith(

      decoration: defaultPinTheme.decoration!.copyWith(

        color: Colors.white,

        border: Border.all(color: AppColors.primary, width: 2),

      ),

    );



    return BlocProvider(

      create: (_) => MfaCubit(),

      child: Scaffold(

        backgroundColor: Colors.white,

        appBar: AppBar(

          backgroundColor: Colors.white,

          elevation: 0,

          leading: IconButton(

            onPressed: () => context.pop(),

            icon: const Icon(

              Icons.arrow_back_ios_new,

              color: AppColors.textPrimary,

            ),

          ),

        ),

        body: BlocConsumer<MfaCubit, MfaState>(

          listener: (context, state) {

            if (state is MfaErrorState) {

              SnackBarPopUp().show(

                context: context,

                message: state.error,

                state: PopUpState.error,

              );

            } else if (state is MfaSuccessState) {

              SnackBarPopUp().show(

                context: context,

                message: LocaleKeys.login_success.tr(),

                state: PopUpState.success,

              );

              context.go(AppRoutes.dashboardScreen);

            } else if (state is MfaResendSuccessState) {

              SnackBarPopUp().show(

                context: context,

                message: 'A new verification code has been sent.',

                state: PopUpState.success,

              );

              _startCountdown();

            } else if (state is MfaResendErrorState) {

              SnackBarPopUp().show(

                context: context,

                message: state.error,

                state: PopUpState.error,

              );

            }

          },

          builder: (context, state) {

            final cubit = context.read<MfaCubit>();

            final isVerifyLoading = state is MfaLoadingState;

            final isResendLoading = state is MfaResendLoadingState;

            final canResend = _secondsRemaining == 0 && !isResendLoading;



            return SafeArea(

              child: Padding(

                padding: EdgeInsets.symmetric(horizontal: 24.w),

                child: SingleChildScrollView(

                  physics: const BouncingScrollPhysics(),

                  child: Form(

                    key: cubit.formKey,

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [

                        SizedBox(height: 32.h),

                        Container(

                          height: 96.h,

                          width: 96.w,

                          decoration: const BoxDecoration(

                            gradient: LinearGradient(

                              colors: [AppColors.primary, AppColors.secondary],

                            ),

                            shape: BoxShape.circle,

                          ),

                          child: Center(

                            child: Icon(

                              Icons.shield_outlined,

                              color: Colors.white,

                              size: 40.sp,

                            ),

                          ),

                        ),

                        SizedBox(height: 24.h),

                        Text(

                          LocaleKeys.mfa_title.tr(),

                          style: TextStyle(

                            fontSize: 24.sp,

                            fontWeight: FontWeight.bold,

                            color: AppColors.textPrimary,

                          ),

                        ),

                        SizedBox(height: 12.h),

                        Text(

                          LocaleKeys.mfa_description.tr(),

                          textAlign: TextAlign.center,

                          style: TextStyle(

                            fontSize: 14.sp,

                            color: AppColors.textSecondary,

                            height: 1.5,

                          ),

                        ),

                        SizedBox(height: 40.h),

                        Pinput(

                          controller: cubit.mfaCode,

                          length: 6,

                          autofocus: true,

                          defaultPinTheme: defaultPinTheme,

                          focusedPinTheme: focusedPinTheme,

                          separatorBuilder: (_) => SizedBox(width: 12.w),

                          hapticFeedbackType: HapticFeedbackType.lightImpact,

                          validator: AppValidator.validateRequired,

                        ),

                        SizedBox(height: 40.h),

                        isVerifyLoading

                            ? const CircularProgressIndicator(

                                valueColor: AlwaysStoppedAnimation(

                                  AppColors.primary,

                                ),

                              )

                            : AppButton(

                                text: LocaleKeys.mfa_confirm_continue.tr(),

                                onPressed: () {

                                  cubit.verifyMfa(mfaToken: token ?? '');

                                },

                              ),

                        SizedBox(height: 24.h),

                        if (AppConfig.isMfaResendEnabled)

                          isResendLoading

                              ? const CircularProgressIndicator(

                                  valueColor: AlwaysStoppedAnimation(

                                    AppColors.primary,

                                  ),

                                )

                              : TextButton(

                                  onPressed: canResend

                                      ? () {

                                          cubit.resendMfa(mfaToken: token ?? '');

                                        }

                                      : null,

                                  child: Text(

                                    canResend

                                        ? LocaleKeys.mfa_resend_code.tr()

                                        : LocaleKeys.mfa_resend_code_in.tr(

                                            args: ['$_secondsRemaining'],

                                          ),

                                    style: TextStyle(

                                      fontSize: 14.sp,

                                      color: canResend

                                          ? AppColors.primary

                                          : AppColors.textSecondary,

                                    ),

                                  ),

                                )

                        else

                          Text(

                            'Resend code is not available yet.',

                            textAlign: TextAlign.center,

                            style: TextStyle(

                              fontSize: 13.sp,

                              color: AppColors.textSecondary,

                            ),

                          ),

                      ],

                    ),

                  ),

                ),

              ),

            );

          },

        ),

      ),

    );

  }

}


