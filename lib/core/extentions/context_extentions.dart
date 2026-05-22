import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../components/custom_alert_box.dart';
import '../components/custom_loading_indicator.dart';
import '../components/custom_snackbar.dart';
import '../config/controllers/language_controller/language_cubit.dart';
import '../config/controllers/theme_controller/theme_cubit.dart';
import '../themes/app_colors.dart';

// -----------------------------------------------------------------------------
// Locale Extension
// -----------------------------------------------------------------------------

extension LocaleExtentions on BuildContext {
  bool get isEn => read<LanguageCubit>().state.locale.languageCode == 'en';
  bool get isAr => read<LanguageCubit>().state.locale.languageCode == 'ar';
}

// -----------------------------------------------------------------------------
// App Colors Extension
// -----------------------------------------------------------------------------
extension AppThemeExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

// -----------------------------------------------------------------------------
// Theme Extension
// -----------------------------------------------------------------------------

extension ThemeExtentions on BuildContext {
  bool get isDarkTheme => read<ThemeCubit>().state.themeMode == ThemeMode.dark;
  bool get isLightTheme => !isDarkTheme;
}

// -----------------------------------------------------------------------------
// Bottom Sheet Extension
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// Alert Dialog Extension
// -----------------------------------------------------------------------------

extension AlertDialogExtension on BuildContext {
  Future<T?> showCustomAlert<T>({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return CustomAlertBox.show<T>(
      context: this,
      child: child,
      padding: padding,
      margin: margin,
    );
  }

  Future<T?> showSuccessAlert<T>({
    String? title,
    String? message,
    String? buttonText,
    String? iconPath,
  }) {
    return SuccessAlertBox.show<T>(
      context: this,
      title: title,
      message: message,
      buttonText: buttonText,
      iconPath: iconPath,
    );
  }

  Future<T?> showWarningAlert<T>({
    String? title,
    required String message,
    String? primaryButtonText,
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
    String? iconPath,
    Color? mainButtonColor,
    Color? secondaryButtonColor,
    Color? mainButtonTextColor,
    Color? secondaryButtonTextColor,
  }) {
    return WarningBox.show<T>(
      context: this,
      title: title,
      message: message,
      primaryButtonText: primaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      secondaryButtonText: secondaryButtonText,
      onSecondaryPressed: onSecondaryPressed,
      iconPath: iconPath,
      mainButtonColor: mainButtonColor,
      secondaryButtonColor: secondaryButtonColor,
      mainButtonTextColor: mainButtonTextColor,
      secondaryButtonTextColor: secondaryButtonTextColor,
    );
  }

  Future<T?> showDialogBox<T>({
    required String message,
    required String mainButtonText,
    required VoidCallback onMainButtonPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryButtonPressed,
  }) {
    return DialogBox.show<T>(
      context: this,
      message: message,
      mainButtonText: mainButtonText,
      onMainButtonPressed: onMainButtonPressed,
      secondaryButtonText: secondaryButtonText,
      onSecondaryButtonPressed: onSecondaryButtonPressed,
    );
  }
}

// -----------------------------------------------------------------------------
// Navigation Extension
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// Responsive Extension
// -----------------------------------------------------------------------------

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isTablet => screenWidth >= 600;
  bool get isMobile => screenWidth < 600;
}

// -----------------------------------------------------------------------------
// Loading Extension
// -----------------------------------------------------------------------------

OverlayEntry? _loadingOverlayEntry;

extension LoadingExtension on BuildContext {
  void showLoadingOverlay() {
    if (_loadingOverlayEntry != null) return;
    _loadingOverlayEntry = OverlayEntry(
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Material(
          color: context.colors.contentDisabled.withAlpha(10),
          child: const Center(child: CustomLoadingIndicator(size: 100)),
        ),
      ),
    );
    Overlay.of(this).insert(_loadingOverlayEntry!);
  }

  void hideLoadingOverlay() {
    _loadingOverlayEntry?.remove();
    _loadingOverlayEntry = null;
  }
}

// -----------------------------------------------------------------------------
// SnackBar Extension
// -----------------------------------------------------------------------------

extension SnackBarExtension on BuildContext {
  void showSuccessSnackBar(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    CustomSnackbar.showSuccess(this, message, duration: duration);
  }

  void showErrorSnackBar(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    CustomSnackbar.showError(this, message, duration: duration);
  }

  void showWarningSnackBar(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    CustomSnackbar.showWarning(this, message, duration: duration);
  }
}
