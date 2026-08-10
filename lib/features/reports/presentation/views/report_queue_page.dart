import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/features/reports/data/datasources/fake_report_remote_data_source.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';
import 'package:spora_app/features/reports/presentation/cubits/report_queue/report_queue_cubit.dart';
import 'package:spora_app/features/reports/presentation/cubits/report_queue/report_queue_state.dart';
import 'package:spora_app/features/reports/presentation/views/create_report_page.dart';
import 'package:spora_app/features/reports/presentation/views/report_details_page.dart';
import 'package:spora_app/features/reports/presentation/views/edit_report_page.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class ReportQueuePage extends StatefulWidget {
  const ReportQueuePage({super.key});

  @override
  State<ReportQueuePage> createState() => _ReportQueuePageState();
}

class _ReportQueuePageState extends State<ReportQueuePage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportQueueCubit>().loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.report_queue_title.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.read<ReportQueueCubit>().syncAll(),
          ),
        ],
      ),
      body: BlocBuilder<ReportQueueCubit, ReportQueueState>(
        builder: (context, state) {
          final cubit = context.read<ReportQueueCubit>();

          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
                color: Colors.grey.shade200,
                child: Row(
                  children: [
                    Text(LocaleKeys.fake_mode_label.tr()),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: DropdownButton<FakeServiceMode>(
                        value: state.fakeServiceMode,
                        isExpanded: true,
                        items: FakeServiceMode.values.map((mode) {
                          return DropdownMenuItem(
                            value: mode,
                            child: Text('mode_${mode.name}'.tr()),
                          );
                        }).toList(),
                        onChanged: (mode) {
                          if (mode != null) cubit.changeFakeServiceMode(mode);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4).r,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(LocaleKeys.filter_all.tr()),
                      selected: state.filterStatus == null,
                      onSelected: (_) => cubit.setFilter(null),
                    ),
                    ...ReportStatusEnum.values.map((status) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: FilterChip(
                          label: Text('status_${status.name}'.tr()),
                          selected: state.filterStatus == status,
                          onSelected: (_) => cubit.setFilter(status),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.filteredReports.isEmpty
                    ? Center(child: Text(LocaleKeys.no_reports_found.tr()))
                    : ListView.builder(
                        itemCount: state.filteredReports.length,
                        itemBuilder: (context, index) {
                          final report = state.filteredReports[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ).r,
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ReportDetailsPage(report: report),
                                  ),
                                );
                              },
                              title: Text(
                                report.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${'category_${report.categoryId}'.tr()} • ${'status_${report.status.name}'.tr()}',
                                  ),
                                  Text(
                                    DateFormat(
                                      'yyyy-MM-dd HH:mm',
                                    ).format(report.createdAt),
                                  ),
                                  if (report.lastError != null)
                                    Text(
                                      '${LocaleKeys.error_label.tr()}: ${report.lastError!.tr()}',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  Text(
                                    '${LocaleKeys.retries_label.tr()}: ${report.retryCount}',
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (report.imagePath != null)
                                    Icon(
                                      Icons.image,
                                      color: Colors.blue,
                                      size: 22.sp,
                                    ),
                                  if (report.status ==
                                          ReportStatusEnum.queued ||
                                      (report.status ==
                                              ReportStatusEnum.failed &&
                                          report.lastError !=
                                              'validation_error'))
                                    IconButton(
                                      icon: Icon(
                                        Icons.refresh,
                                        color: Colors.orange,
                                        size: 22.sp,
                                      ),
                                      onPressed: () =>
                                          cubit.retryReport(report.localId),
                                    ),
                                  if (report.status == ReportStatusEnum.draft ||
                                      (report.status ==
                                              ReportStatusEnum.failed &&
                                          report.lastError ==
                                              'validation_error'))
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 22.sp,
                                      ),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditReportPage(report: report),
                                          ),
                                        );
                                        cubit.loadReports();
                                      },
                                    ),
                                  if (report.status == ReportStatusEnum.draft)
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 22.sp,
                                      ),
                                      onPressed: () =>
                                          cubit.deleteDraft(report.localId),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateReportPage()),
          );
          if (context.mounted) {
            context.read<ReportQueueCubit>().loadReports();
          }
        },
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }
}
