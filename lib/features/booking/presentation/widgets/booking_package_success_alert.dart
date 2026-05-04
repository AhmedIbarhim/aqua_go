import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_alert_box.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class BookingPackageSuccessAlert extends StatelessWidget {
  const BookingPackageSuccessAlert({super.key});

  static Future<T?> show<T>(BuildContext context) {
    return CustomAlertBox.show<T>(
      context: context,
      child: const BookingPackageSuccessAlert(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success Icon
        SvgPicture.asset(AppAssets.successIcon, width: 112, height: 112),
        const SizedBox(height: 16),

        // Title
        Text(LocaleKeys.success.tr(), style: AppTextStyles.medium16),
        const SizedBox(height: 4),

        // Description
        Text(
          LocaleKeys.booking_package_booking_success.tr(),
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
    );
  }
}
