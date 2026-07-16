import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/core/theme/theme_helper.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(super.initialTheme);

  void changeTheme(ThemeMode themeMode) async {
    emit(themeMode);
    await ThemeCacheHelper().cacheThemeMode(themeMode);
  }
}
