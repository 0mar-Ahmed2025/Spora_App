import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spora_app/features/device_capabilities/models/location_data_model.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class LocationResultSheet extends StatelessWidget {
  const LocationResultSheet({super.key, required this.locationData});

  final LocationDataModel locationData;

  String _formatRetrievalTime(DateTime time) {
    final local = time.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final ss = local.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

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
                    LocaleKeys.device_capabilities_get_location.tr(),
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
              SizedBox(height: 8.h),
              _buildDetailRow(
                LocaleKeys.device_capabilities_latitude.tr(),
                locationData.latitude.toStringAsFixed(6),
              ),
              _buildDetailRow(
                LocaleKeys.device_capabilities_longitude.tr(),
                locationData.longitude.toStringAsFixed(6),
              ),
              _buildDetailRow(
                LocaleKeys.device_capabilities_accuracy.tr(),
                '${locationData.accuracy.toStringAsFixed(1)} m',
              ),
              _buildDetailRow(
                LocaleKeys.device_capabilities_retrieval_time.tr(),
                _formatRetrievalTime(locationData.retrievalTime),
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
