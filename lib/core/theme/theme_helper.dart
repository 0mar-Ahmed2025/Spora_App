import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCacheHelper {
  static const String _themeKey = "THEME_MODE";

  Future<void> cacheThemeMode(ThemeMode themeMode) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt(_themeKey, themeMode.index);
  }

  Future<ThemeMode> getCachedThemeMode() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeIndex = sharedPreferences.getInt(_themeKey);

    if (themeIndex != null) {
      return ThemeMode.values[themeIndex];
    }
    return ThemeMode.system;
  }
}
