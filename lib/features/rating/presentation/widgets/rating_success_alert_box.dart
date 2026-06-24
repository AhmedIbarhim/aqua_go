import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_button.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class RatingSuccessAlertBox extends StatelessWidget {
  const RatingSuccessAlertBox({super.key});

  static Future<T?> show<T>(
    BuildContext context, {
    bool autoDismiss = true,
    // AQG-160: the success confirmation auto-hides after ~2s (no manual close
    // required on the home rating popup path).
    Duration dismissDuration = const Duration(seconds: 2),
  }) {
    return context.showCustomAlert<T>(
      child: const RatingSuccessAlertBox(),
      autoDismiss: autoDismiss,
      dismissDuration: dismissDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppAssets.successIcon,
          width: width * 0.28,
          height: width * 0.28,
        ),
        SizedBox(height: height * 0.02),

        Text(
          LocaleKeys.bookings_rating_submitted.tr(context: context),
          style: AppTextStyles.medium16,
        ),
        const SizedBox(height: 4),

        // Description
        Text(
          LocaleKeys.bookings_rating_submitted_desc.tr(context: context),
          textAlign: TextAlign.center,
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: height * 0.03),

        CustomButton(
          text: LocaleKeys.go_to_home.tr(context: context),
          onPressed: () => context.pushNamed(Routes.layout),
        ),
      ],
    );
  }
}
