import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/features/reports/domain/models/local_report_model.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class ReportDetailsPage extends StatelessWidget {
  const ReportDetailsPage({super.key, required this.report});

  final LocalReportModel report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.report_details.tr())),
      body: SingleChildScrollView(
        padding: REdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Divider(height: 32.h),
            _buildDetailSection(),
            if (report.lastError != null) ...[
              Divider(height: 32.h),
              _buildErrorSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                report.title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildStatusChip(),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildInfoChip(
              'category_${report.categoryId}'.tr(),
              Icons.category,
            ),
            SizedBox(width: 8.w),
            _buildInfoChip(
              'priority_${report.priority.name}'.tr(),
              Icons.flag,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    Color color;
    switch (report.status) {
      case ReportStatusEnum.submitted:
        color = Colors.green;
        break;
      case ReportStatusEnum.failed:
        color = Colors.red;
        break;
      case ReportStatusEnum.sending:
        color = Colors.orange;
        break;
      case ReportStatusEnum.queued:
        color = Colors.blue;
        break;
      case ReportStatusEnum.draft:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        'status_${report.status.name}'.tr(),
        style: TextStyle(color: Colors.white, fontSize: 12.sp),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16.sp),
      label: Text(label, style: TextStyle(fontSize: 12.sp)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildDetailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.field_description.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          report.description,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16.h),
        _buildDetailRow(
          LocaleKeys.detail_created_at.tr(),
          DateFormat('yyyy-MM-dd HH:mm').format(report.createdAt),
        ),
        _buildDetailRow(
          LocaleKeys.detail_updated_at.tr(),
          DateFormat('yyyy-MM-dd HH:mm').format(report.updatedAt),
        ),
        _buildDetailRow(
          LocaleKeys.retries_label.tr(),
          report.retryCount.toString(),
        ),
        if (report.serverId != null)
          _buildDetailRow(
            LocaleKeys.detail_server_id.tr(),
            report.serverId!,
          ),
        if (report.latitude != null && report.longitude != null)
          _buildDetailRow(
            LocaleKeys.detail_coordinates.tr(),
            '${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}',
          )
        else
          _buildDetailRow(
            LocaleKeys.detail_coordinates.tr(),
            LocaleKeys.detail_no_location.tr(),
          ),
        if (report.imagePath != null) ...[
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.file(
              File(report.imagePath!),
              height: 200.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100.h,
                color: Colors.grey.shade200,
                child: Center(child: Icon(Icons.broken_image, size: 50.sp)),
              ),
            ),
          ),
        ] else ...[
          SizedBox(height: 16.h),
          Container(
            height: 100.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 40.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 4.h),
                Text(
                  LocaleKeys.detail_no_image.tr(),
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              LocaleKeys.error_label.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: REdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Text(
            report.lastError!.tr(),
            style: TextStyle(color: Colors.red.shade700, fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}
