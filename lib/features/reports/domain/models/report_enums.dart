enum ReportStatusEnum {
  draft,
  queued,
  sending,
  submitted,
  failed;

  static ReportStatusEnum fromString(String status) {
    return ReportStatusEnum.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ReportStatusEnum.draft,
    );
  }
}

enum ReportPriorityEnum {
  low,
  normal,
  high,
  urgent;

  static ReportPriorityEnum fromString(String priority) {
    return ReportPriorityEnum.values.firstWhere(
      (e) => e.name == priority,
      orElse: () => ReportPriorityEnum.normal,
    );
  }
}
