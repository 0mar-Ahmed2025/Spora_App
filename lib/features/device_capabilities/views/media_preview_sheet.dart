import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
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
                  style: const TextStyle(
                    fontSize: 18,
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
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(mediaFile.path),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 100,
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.device_capabilities_close.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
