import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/core/shared/logout_button.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/features/dashboard/cubits/get_profile_data/get_profile_cubit.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';
import 'package:spora_app/features/device_capabilities/widgets/device_capabilities_section.dart';
import 'package:spora_app/features/profile/view/profile_screen.dart';
import 'package:spora_app/features/dashboard/views/security_view.dart';
import 'package:spora_app/features/dashboard/widgets/custom_account_status_widget.dart';
import 'package:spora_app/features/dashboard/widgets/custom_app_bar_widget.dart';
import 'package:spora_app/features/dashboard/widgets/quick_access_tile_widget.dart';
import 'package:spora_app/features/reports/data/datasources/fake_report_remote_data_source.dart';
import 'package:spora_app/features/reports/data/datasources/local_report_data_source.dart';
import 'package:spora_app/features/reports/domain/repositories/report_repository_impl.dart';
import 'package:spora_app/features/reports/presentation/cubits/create_report/create_report_cubit.dart';
import 'package:spora_app/features/reports/presentation/cubits/report_queue/report_queue_cubit.dart';
import 'package:spora_app/features/reports/presentation/views/create_report_page.dart';
import 'package:spora_app/features/reports/presentation/views/report_queue_page.dart';
import 'package:spora_app/features/settings/view/setting_view.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class DashboardSuccessStateWidget extends StatelessWidget {
  const DashboardSuccessStateWidget({super.key, required this.user});

  final UserData user;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tileBackground = isDarkMode
        ? AppColors.darkSurface
        : AppColors.background;
    final textPrimary = isDarkMode
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDarkMode
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(userData: user, imageUrl: user.avatarUrl),
          SizedBox(height: 24.h),

          CustomAccountStatus(isActive: user.isActive),
          SizedBox(height: 32.h),

          Text(
            LocaleKeys.dashboard_quick_actions.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          QuickAccessTile(
            sporaBackgroundGray: tileBackground,
            sporaPurple: AppColors.primary,
            sporaTextDark: textPrimary,
            sporaTextMuted: textSecondary,
            icon: Icons.person_search_outlined,
            title: LocaleKeys.dashboard_profile_title.tr(),
            subtitle: LocaleKeys.dashboard_profile_subtitle.tr(),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ProfileScreen();
                  },
                ),
              );

              if (context.mounted) {
                GetProfileCubit.get(context).getProfileData();
              }
            },
          ),
          SizedBox(height: 12.h),
          QuickAccessTile(
            sporaBackgroundGray: tileBackground,
            sporaPurple: AppColors.primary,
            sporaTextDark: textPrimary,
            sporaTextMuted: textSecondary,
            icon: Icons.security_outlined,
            title: LocaleKeys.dashboard_security_title.tr(),
            subtitle: LocaleKeys.dashboard_security_subtitle.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SecurityView();
                  },
                ),
              );
            },
          ),
          SizedBox(height: 12.h),
          QuickAccessTile(
            sporaBackgroundGray: tileBackground,
            sporaPurple: AppColors.primary,
            sporaTextDark: textPrimary,
            sporaTextMuted: textSecondary,
            icon: Icons.settings_outlined,
            title: LocaleKeys.dashboard_settings_title.tr(),
            subtitle: LocaleKeys.dashboard_settings_subtitle.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsScreen();
                  },
                ),
              );
            },
          ),
          QuickAccessTile(
            sporaBackgroundGray: tileBackground,
            sporaPurple: AppColors.primary,
            sporaTextDark: textPrimary,
            sporaTextMuted: textSecondary,
            icon: Icons.add,
            title: LocaleKeys.create_report_title.tr(),
            subtitle: LocaleKeys.create_report_title.tr(),
            onTap: () {
              final localDataSource = LocalReportDataSourceImpl();
              final remoteDataSource = FakeReportRemoteDataSourceImpl();
              final repository = ReportRepositoryImpl(
                localDataSource: localDataSource,
                remoteDataSource: remoteDataSource,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => CreateReportCubit(repository: repository),
                    child: const CreateReportPage(),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 12.h),

          QuickAccessTile(
            sporaBackgroundGray: tileBackground,
            sporaPurple: AppColors.primary,
            sporaTextDark: textPrimary,
            sporaTextMuted: textSecondary,
            icon: Icons.format_list_bulleted_outlined,
            title: LocaleKeys.report_queue_title.tr(),
            subtitle: LocaleKeys.report_queue_title.tr(),
            onTap: () {
              final localDataSource = LocalReportDataSourceImpl();
              final remoteDataSource = FakeReportRemoteDataSourceImpl();
              final repository = ReportRepositoryImpl(
                localDataSource: localDataSource,
                remoteDataSource: remoteDataSource,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => ReportQueueCubit(
                      repository: repository,
                      remoteDataSource: remoteDataSource,
                    ),
                    child: const ReportQueuePage(),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 32.h),

          Text(
            LocaleKeys.device_capabilities_section_title.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          const DeviceCapabilitiesSection(),

          SizedBox(height: 32.h),

          const LogoutButton(),
        ],
      ),
    );
  }
}
