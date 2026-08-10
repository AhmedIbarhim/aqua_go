import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

extension AppThemeExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

extension ThemeExtentions on BuildContext {
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
  bool get isLightTheme => !isDarkTheme;
}
