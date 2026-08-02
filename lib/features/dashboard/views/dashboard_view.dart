// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/core/shared/custom_loading.dart';
import 'package:spora_app/features/dashboard/cubits/get_profile_data/get_profile_cubit.dart';
import 'package:spora_app/features/dashboard/cubits/get_profile_data/get_profile_state.dart';
import 'package:spora_app/features/dashboard/widgets/dashboard_error_widget.dart';
import 'package:spora_app/features/dashboard/widgets/dashboard_success_widget.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final brightness = Theme.of(context).brightness;

    return BlocProvider(
      create: (context) => GetProfileCubit()..getProfileData(),
      child: Scaffold(
        body: BlocBuilder<GetProfileCubit, GetProfileState>(
          builder: (context, state) {
            var cubit = GetProfileCubit.get(context);
            if (state is GetProfileErrorState) {
              return DashboardErrorStateWidget(
                cubit: cubit,
                errorMessage: state.error, 
              );
            } else if (state is GetProfileLoadingState) {
              return CustomLoadingWidget();
            } else if (state is EmptyProfileState) {
              return Container(color: Colors.red);
            } else if (state is GetProfileSuccessState) {
              return DashboardSuccessStateWidget(
                key: ValueKey(
                  'dashboard-${locale.languageCode}-${brightness.name}',
                ),
                user: state.userModel,
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
