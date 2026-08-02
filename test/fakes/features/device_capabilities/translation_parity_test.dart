import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verify all localization JSON files contain identical keys', () async {
    final enJson = jsonDecode(
      File('assets/translations/en.json').readAsStringSync(),
    );
    final arJson = jsonDecode(
      File('assets/translations/ar.json').readAsStringSync(),
    );
    final faJson = jsonDecode(
      File('assets/translations/fa.json').readAsStringSync(),
    );

    Set<String> extractKeys(Map<String, dynamic> json, [String prefix = '']) {
      final keys = <String>{};
      json.forEach((key, value) {
        final currentKey = prefix.isEmpty ? key : '$prefix.$key';
        if (value is Map<String, dynamic>) {
          keys.addAll(extractKeys(value, currentKey));
        } else {
          keys.add(currentKey);
        }
      });
      return keys;
    }

    final enKeys = extractKeys(enJson);
    final arKeys = extractKeys(arJson);
    final faKeys = extractKeys(faJson);

    expect(
      arKeys,
      equals(enKeys),
      reason: 'Arabic keys do not match English keys',
    );
    expect(
      faKeys,
      equals(enKeys),
      reason: 'Persian keys do not match English keys',
    );
  });
}
