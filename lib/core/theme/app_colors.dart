import 'package:flutter/material.dart';

abstract class AppColors {
  // Shared Colors 
  static const Color primary = Color(0xFF916BFF);
  static const Color secondary = Color(0xFF5168FF);
  static const Color success = Color(0xFF7FBA7A);
  static const Color error = Color(0xFFFF754D);
  static const Color chartBlue = Color(0xFF3F8CFF);
  static const Color chartYellow = Color(0xFFFFB23E);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Light Mode Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF11142D);
  static const Color textSecondary = Color(0xFF8A94A6);
  static const Color enabledBorderSideColor = Color(0xFFE4E4E4);

  // Dark Mode Colors 
  static const Color darkBackground = Color(0xFF121212); 
  static const Color darkSurface = Color(0xFF1E1E1E); 
  static const Color darkTextPrimary = Color(0xFFFFFFFF); 
  static const Color darkTextSecondary = Color(0xFFB0B3B8); 
  static const Color darkEnabledBorderSideColor = Color(0xFF333333); 
}