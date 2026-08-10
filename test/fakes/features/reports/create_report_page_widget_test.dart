import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spora_app/core/errors/failures.dart';
import 'package:spora_app/features/reports/domain/models/local_report_model.dart';
import 'package:spora_app/features/reports/domain/repositories/report_repository.dart';
import 'package:spora_app/features/reports/presentation/cubits/create_report/create_report_cubit.dart';
import 'package:spora_app/features/reports/presentation/views/create_report_page.dart';
import 'package:spora_app/generated/codegen_loader.g.dart';

class StorageFailingReportRepository implements ReportRepository {
  @override
  Future<void> createReport(LocalReportModel report) async {
    throw const StorageFailure();
  }

  @override
  Future<void> deleteReport(String localId) async {}

  @override
  Future<List<LocalReportModel>> getAllReports() async => [];

  @override
  Future<void> submitReport(String localId) async {}

  @override
  Future<void> syncAllReports() async {}

  @override
  Future<void> updateReport(LocalReportModel report) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('storage failures render a translated snackbar', (tester) async {
    final cubit = CreateReportCubit(
      repository: StorageFailingReportRepository(),
    )
      ..titleChanged('Broken water pipe')
      ..descriptionChanged('Water is leaking in the main hall')
      ..categoryChanged('technical');

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        assetLoader: const CodegenLoader(),
        child: Builder(
          builder: (context) {
            return ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              builder: (context, child) {
                return MaterialApp(
                  locale: context.locale,
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  home: BlocProvider<CreateReportCubit>.value(
                    value: cubit,
                    child: const CreateReportPage(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Report'));
    await tester.pumpAndSettle();

    expect(find.text('Failed to save locally.'), findsOneWidget);
    expect(find.text('storage_error'), findsNothing);

    await cubit.close();
  });
}
