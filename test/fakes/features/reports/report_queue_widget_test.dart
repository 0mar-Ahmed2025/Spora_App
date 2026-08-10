import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spora_app/features/reports/data/datasources/fake_report_remote_data_source.dart';
import 'package:spora_app/features/reports/domain/models/local_report_model.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';
import 'package:spora_app/features/reports/domain/repositories/report_repository.dart';
import 'package:spora_app/features/reports/presentation/cubits/report_queue/report_queue_cubit.dart';
import 'package:spora_app/features/reports/presentation/views/report_queue_page.dart';
import 'package:spora_app/generated/codegen_loader.g.dart';

class MockReportRepository extends Mock implements ReportRepository {}

LocalReportModel buildReport({
  required String localId,
  required String title,
  required ReportStatusEnum status,
  String? lastError,
}) {
  return LocalReportModel(
    localId: localId,
    title: title,
    description: 'Description for $title',
    categoryId: 'technical',
    priority: ReportPriorityEnum.normal,
    status: status,
    lastError: lastError,
    createdAt: DateTime(2026, 1, 1, 10, 0),
    updatedAt: DateTime(2026, 1, 1, 10, 0),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockReportRepository repository;
  late ReportQueueCubit cubit;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    repository = MockReportRepository();
    cubit = ReportQueueCubit(
      repository: repository,
      remoteDataSource: FakeReportRemoteDataSourceImpl(),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  Future<void> pumpQueueScreen(
    WidgetTester tester, {
    required List<LocalReportModel> reports,
  }) async {
    when(() => repository.getAllReports()).thenAnswer((_) async => reports);
    when(() => repository.submitReport(any())).thenAnswer((_) async {});

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
                  home: BlocProvider<ReportQueueCubit>.value(
                    value: cubit,
                    child: const ReportQueuePage(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders reports in the queue screen', (tester) async {
    final reports = [
      buildReport(
        localId: 'submitted-1',
        title: 'Submitted report',
        status: ReportStatusEnum.submitted,
      ),
      buildReport(
        localId: 'failed-1',
        title: 'Failed report',
        status: ReportStatusEnum.failed,
        lastError: 'network_unavailable',
      ),
    ];

    await pumpQueueScreen(tester, reports: reports);

    expect(find.text('Submitted report'), findsOneWidget);
    expect(find.text('Failed report'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
  });

  testWidgets('failed report exposes a retry action', (tester) async {
    final reports = [
      buildReport(
        localId: 'failed-1',
        title: 'Failed report',
        status: ReportStatusEnum.failed,
        lastError: 'network_unavailable',
      ),
    ];

    await pumpQueueScreen(tester, reports: reports);

    expect(find.byIcon(Icons.refresh), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    verify(() => repository.submitReport('failed-1')).called(1);
  });

  testWidgets('submitted report does not show a retry action', (tester) async {
    final reports = [
      buildReport(
        localId: 'submitted-1',
        title: 'Submitted report',
        status: ReportStatusEnum.submitted,
      ),
    ];

    await pumpQueueScreen(tester, reports: reports);

    expect(find.byIcon(Icons.refresh), findsNothing);
  });

  testWidgets('validation failed report exposes edit but not retry',
      (tester) async {
    final reports = [
      buildReport(
        localId: 'validation-1',
        title: 'Validation failed report',
        status: ReportStatusEnum.failed,
        lastError: 'validation_error',
      ),
    ];

    await pumpQueueScreen(tester, reports: reports);

    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byIcon(Icons.edit), findsOneWidget);
  });
}
