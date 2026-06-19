import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/route/app_router.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../booking/domain/configs/booking_flow_config.dart';
import '../../../booking/domain/strategies/package_booking_submit.dart';

class PackageSubscribtionSuccessAlert extends StatelessWidget {
  final String? referenceNumber;
  final String? subscriptionId;

  const PackageSubscribtionSuccessAlert({
    super.key,
    this.referenceNumber,
    this.subscriptionId,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    String? referenceNumber,
    String? subscriptionId,
  }) {
    return context.showCustomAlert<T>(
      child: PackageSubscribtionSuccessAlert(
        referenceNumber: referenceNumber,
        subscriptionId: subscriptionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success Icon
        SvgPicture.asset(
          AppAssets.successIcon,
          width: width * 0.28,
          height: width * 0.28,
        ),
        SizedBox(height: height * 0.02),

        // Title
        Text(LocaleKeys.success.tr(), style: AppTextStyles.medium16),
        if (referenceNumber != null) ...[
          const SizedBox(height: 4),
          Text(
            referenceNumber!,
            style: AppTextStyles.medium14.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 8),

        // Description
        Text(
          LocaleKeys.booking_package_booking_success.tr(),
          textAlign: TextAlign.center,
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: height * 0.03),

        // Primary Button
        CustomButton(
          text: LocaleKeys.booking_package_request_wash.tr(),
          onPressed: () {
            context.pop();
            context.pushNamed(
              Routes.bookingLocation,
              arguments: BookingFlowStartArgs(
                flowConfig: const BookingFlowConfig(
                  flowType: BookingFlowType.package,
                ),
                submitStrategy: const PackageBookingSubmit(),
                subscriptionId: subscriptionId,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Secondary Button
        CustomButton(
          text: LocaleKeys.go_to_home.tr(),
          color: context.colors.cardBackGround,
          borderColor: context.colors.borderSecondary,
          textColor: context.colors.primary,
          onPressed: () {
            context.pop();
            context.pushNamedAndRemoveUntil(Routes.layout);
          },
        ),
      ],
    );
  }
}
