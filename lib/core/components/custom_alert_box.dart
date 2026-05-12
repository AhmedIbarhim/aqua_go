import 'dart:ui' as ui;
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../generated/locale_keys.g.dart';
import '../themes/app_text_styles.dart';
import '../utils/app_assets.dart';
import 'custom_button.dart';

class CustomAlertBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const CustomAlertBox({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: CustomAlertBox(padding: padding, margin: margin, child: child),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tap from bubbling up to background
            child: Container(
              width: double.infinity,
              margin: margin ?? EdgeInsets.symmetric(horizontal: width * 0.06),
              padding: padding ?? EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: context.colors.cardBackGround,
                borderRadius: BorderRadius.circular(24),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessAlertBox extends StatelessWidget {
  const SuccessAlertBox({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    // this.onPressed,
  });

  final String? title;
  final String? message;
  final String? buttonText;
  // final VoidCallback? onPressed;

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    String? buttonText,
    // VoidCallback? onPressed,
  }) {
    return CustomAlertBox.show<T>(
      context: context,
      child: SuccessAlertBox(
        title: title,
        message: message,
        buttonText: buttonText,
        // onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success Icon
        SvgPicture.asset(
          AppAssets.successIcon,
          width: width * 0.28,
          height: width * 0.28,
        ),
        SizedBox(height: width * 0.04),

        // Title
        Text(title ?? LocaleKeys.success.tr(), style: AppTextStyles.medium16),
        const SizedBox(height: 4),

        // Description
        if (message != null)
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTextStyles.regular16.copyWith(
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
        SizedBox(height: width * 0.06),
      ],
    );
  }
}

class WarningBox extends StatelessWidget {
  const WarningBox({
    super.key,
    this.title,
    required this.message,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  final String? title;
  final String message;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required String message,
    String? primaryButtonText,
    VoidCallback? onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
  }) {
    return CustomAlertBox.show<T>(
      context: context,
      child: WarningBox(
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        secondaryButtonText: secondaryButtonText,
        onSecondaryPressed: onSecondaryPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Warning Icon
        SvgPicture.asset(
          AppAssets.warningIcon,
          width: width * 0.28,
          height: width * 0.28,
        ),
        SizedBox(height: width * 0.04),

        // Title
        if (title != null) ...[
          Text(title!, style: AppTextStyles.medium16),
          const SizedBox(height: 4),
        ],

        // Description
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: width * 0.06),

        Row(
          children: [
            Expanded(
              child: CustomButton(
                color: context.colors.error,
                borderColor: context.colors.error,
                text: primaryButtonText ?? LocaleKeys.delete.tr(),
                textColor: lightAppColors.themeColor,
                onPressed: onPrimaryPressed ?? () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: width * 0.02),

            Expanded(
              child: CustomButton(
                text: secondaryButtonText ?? LocaleKeys.back.tr(),
                color: context.colors.cardBackGround,
                borderColor: context.colors.borderSecondary,
                textColor: context.colors.textPrimary,
                onPressed: onSecondaryPressed ?? () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
