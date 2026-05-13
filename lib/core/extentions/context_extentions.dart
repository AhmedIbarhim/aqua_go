import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/controllers/language_controller/language_cubit.dart';
import '../config/controllers/theme_controller/theme_cubit.dart';

extension LocaleExtentions on BuildContext {
  bool get isEn => read<LanguageCubit>().state.locale.languageCode == 'en';
  bool get isAr => read<LanguageCubit>().state.locale.languageCode == 'ar';
}

extension ThemeExtentions on BuildContext {
  bool get isDarkTheme => read<ThemeCubit>().state.themeMode == ThemeMode.dark;
  bool get isLightTheme => !isDarkTheme;
}

extension BottomSheetExtension on BuildContext {
  void showCustomBottomSheet({required Widget child}) {
    showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => child,
    );
  }
}

extension NavigatorExtension on BuildContext {
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop(result);
  }

  bool canPop() {
    return Navigator.of(this).canPop();
  }
}

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isTablet => screenWidth >= 600;
  bool get isMobile => screenWidth < 600;
}
