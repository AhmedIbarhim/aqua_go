import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class BookingPackageSuccessAlert extends StatelessWidget {
  const BookingPackageSuccessAlert({super.key});

  static Future<T?> show<T>(BuildContext context) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: const BookingPackageSuccessAlert(),
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.cardBackGround,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              SvgPicture.asset(AppAssets.successIcon, width: 112, height: 112),
              const SizedBox(height: 16),

              // Title
              Text(
                LocaleKeys.booking_package_success.tr(),
                style: AppTextStyles.medium16,
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                LocaleKeys.booking_package_description.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.regular16.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Primary Button
              CustomButton(
                text: LocaleKeys.booking_package_request_wash.tr(),
                onPressed: () {
                  context.pop();
                  // TODO: Implement navigation to request wash
                },
              ),
              const SizedBox(height: 16),

              // Secondary Button
              CustomButton(
                text: LocaleKeys.booking_package_go_to_home.tr(),
                color: context.colors.cardBackGround,
                borderColor: context.colors.borderSecondary,
                textColor: context.colors.primary,
                onPressed: () {
                  context.pop();
                  // TODO: Implement navigation to home
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
