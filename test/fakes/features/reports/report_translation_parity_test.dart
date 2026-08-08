import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final reportKeys = [
    'create_report_title',
    'report_saved_success',
    'field_title',
    'error_title_invalid',
    'field_description',
    'error_description_invalid',
    'field_category',
    'field_priority',
    'btn_camera',
    'btn_gallery',
    'btn_save',
    'btn_save_draft',
    'field_location',
    'btn_get_location',
    'location_fetched',
    'location_cleared',
    'report_queue_title',
    'fake_mode_label',
    'filter_all',
    'no_reports_found',
    'error_label',
    'retries_label',
    'category_technical',
    'category_service',
    'category_feedback',
    'category_other',
    'priority_low',
    'priority_normal',
    'priority_high',
    'priority_urgent',
    'status_draft',
    'status_queued',
    'status_sending',
    'status_submitted',
    'status_failed',
    'mode_success',
    'mode_offline',
    'mode_timeout',
    'mode_serverError',
    'mode_validationError',
    'network_unavailable',
    'timeout',
    'server_error',
    'validation_error',
    'file_missing',
    'storage_error',
    'unknown_error',
    'report_details',
    'detail_created_at',
    'detail_updated_at',
    'detail_server_id',
    'detail_coordinates',
    'detail_no_location',
    'detail_no_image',
    'btn_edit',
    'report_updated_success',
  ];

  late Map<String, dynamic> enJson;
  late Map<String, dynamic> arJson;
  late Map<String, dynamic> faJson;

  setUpAll(() {
    enJson = jsonDecode(
      File('assets/translations/en.json').readAsStringSync(),
    );
    arJson = jsonDecode(
      File('assets/translations/ar.json').readAsStringSync(),
    );
    faJson = jsonDecode(
      File('assets/translations/fa.json').readAsStringSync(),
    );
  });

  test('every report feature key exists in English', () {
    for (final key in reportKeys) {
      expect(
        enJson.containsKey(key),
        isTrue,
        reason: 'Missing English key: $key',
      );
    }
  });

  test('every report feature key exists in Arabic', () {
    for (final key in reportKeys) {
      expect(
        arJson.containsKey(key),
        isTrue,
        reason: 'Missing Arabic key: $key',
      );
    }
  });

  test('every report feature key exists in Persian', () {
    for (final key in reportKeys) {
      expect(
        faJson.containsKey(key),
        isTrue,
        reason: 'Missing Persian key: $key',
      );
    }
  });
}
