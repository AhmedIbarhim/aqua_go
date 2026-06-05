import 'package:flutter/material.dart';
import '../../components/custom_alert_box.dart';

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
