import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 32),
            _buildDetailSection(),
            if (report.lastError != null) ...[
              const Divider(height: 32),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildStatusChip(),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoChip(
              'category_${report.categoryId}'.tr(),
              Icons.category,
            ),
            const SizedBox(width: 8),
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
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          report.description,
          style: TextStyle(color: Colors.grey.shade700, height: 1.5),
        ),
        const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(report.imagePath!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.broken_image, size: 50)),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                const SizedBox(height: 4),
                Text(
                  LocaleKeys.detail_no_image.tr(),
                  style: const TextStyle(color: Colors.grey),
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
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              LocaleKeys.error_label.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Text(
            report.lastError!.tr(),
            style: TextStyle(color: Colors.red.shade700),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
