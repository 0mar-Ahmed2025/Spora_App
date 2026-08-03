import 'package:equatable/equatable.dart';
import 'package:spora_app/features/reports/data/datasources/fake_report_remote_data_source.dart';
import 'package:spora_app/features/reports/domain/models/local_report_model.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';

class ReportQueueState extends Equatable {
  final List<LocalReportModel> allReports;
  final ReportStatusEnum? filterStatus;
  final FakeServiceMode fakeServiceMode;
  final bool isLoading;

  const ReportQueueState({
    this.allReports = const [],
    this.filterStatus,
    this.fakeServiceMode = FakeServiceMode.success,
    this.isLoading = false,
  });

  List<LocalReportModel> get filteredReports {
    if (filterStatus == null) return allReports;
    return allReports.where((r) => r.status == filterStatus).toList();
  }

  ReportQueueState copyWith({
    List<LocalReportModel>? allReports,
    ReportStatusEnum? filterStatus,
    bool clearFilter = false,
    FakeServiceMode? fakeServiceMode,
    bool? isLoading,
  }) {
    return ReportQueueState(
      allReports: allReports ?? this.allReports,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
      fakeServiceMode: fakeServiceMode ?? this.fakeServiceMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    allReports,
    filterStatus,
    fakeServiceMode,
    isLoading,
  ];
}
