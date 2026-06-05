import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/controllers/theme_controller/theme_cubit.dart';
import '../../themes/app_colors.dart';

extension AppThemeExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

extension ThemeExtentions on BuildContext {
  bool get isDarkTheme => read<ThemeCubit>().state.themeMode == ThemeMode.dark;
  bool get isLightTheme => !isDarkTheme;
}
