import 'package:easy_localization/easy_localization.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

abstract class AppValidator {
  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.required_field.tr();
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final requiredError = validateRequired(value);
    if (requiredError != null) return requiredError;

    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }
}
