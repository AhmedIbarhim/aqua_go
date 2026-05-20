import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial(_getInitialThemeMode()));

  static ThemeMode _getInitialThemeMode() {
    final themeStr = CacheClient.getString(kThemeMode);
    if (themeStr == 'dark') {
      return ThemeMode.dark;
    } else if (themeStr == 'light') {
      return ThemeMode.light;
    }
    return ThemeMode
        .dark; // Defaulting to dark as requested by design previously
  }

  Future<void> toggleTheme(bool isDark) async {
    final newThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await CacheClient.setString(kThemeMode, isDark ? 'dark' : 'light');
    emit(ThemeChanged(newThemeMode));
  }
}
