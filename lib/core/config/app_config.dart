import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static bool get isMfaResendEnabled =>
      dotenv.env['MFA_RESEND_ENABLED']?.toLowerCase() == 'true';

  static bool get isRegisterEnabled =>
      dotenv.env['REGISTER_ENABLED']?.toLowerCase() == 'true';
}
