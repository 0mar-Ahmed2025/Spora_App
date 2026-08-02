import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/generated/locale_keys.g.dart';
import '../models/media_file_model.dart';

class MediaPreviewSheet extends StatelessWidget {
  const MediaPreviewSheet({super.key, required this.mediaFile});

  final MediaFileModel mediaFile;

  bool get _isImage => [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ].contains(mediaFile.fileType.toLowerCase());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: REdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.device_capabilities_file_info.tr(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              if (_isImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    File(mediaFile.path),
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => SizedBox(
                      height: 100.h,
                      child: Icon(
                        Icons.broken_image,
                        size: 50.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              _buildDetailRow(
                LocaleKeys.device_capabilities_file_name.tr(),
                mediaFile.name,
              ),
              _buildDetailRow(
                LocaleKeys.device_capabilities_file_type.tr(),
                mediaFile.fileType.toUpperCase(),
              ),
              _buildDetailRow(
                LocaleKeys.device_capabilities_file_size.tr(),
                mediaFile.formattedSize,
              ),
              _buildDetailRow(
                LocaleKeys.device_capabilities_file_path.tr(),
                mediaFile.path,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.device_capabilities_close.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
