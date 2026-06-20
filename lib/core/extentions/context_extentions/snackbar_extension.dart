import 'package:flutter/material.dart';
import '../../components/custom_snackbar.dart';

extension SnackBarExtension on BuildContext {
  void showSuccessSnackBar(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 2),
  }) {
    CustomSnackbar.showSuccess(this, message, duration: duration);
  }

  void showErrorSnackBar(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 2),
  }) {
    CustomSnackbar.showError(this, message, duration: duration);
  }

  void showWarningSnackBar(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 2),
  }) {
    CustomSnackbar.showWarning(this, message, duration: duration);
  }
}
