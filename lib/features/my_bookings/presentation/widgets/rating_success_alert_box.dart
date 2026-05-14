import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_alert_box.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';

class RatingSuccessAlertBox extends StatelessWidget {
  const RatingSuccessAlertBox({super.key});

  static Future<T?> show<T>(BuildContext context) {
    return CustomAlertBox.show<T>(
      context: context,
      child: const RatingSuccessAlertBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
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
        Text(
          LocaleKeys.bookings_rating_submitted.tr(),
          style: AppTextStyles.medium16,
        ),
        const SizedBox(height: 4),

        // Description
        Text(
          LocaleKeys.bookings_rating_submitted_desc.tr(),
          textAlign: TextAlign.center,
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: height * 0.03),

        // OK Button
        CustomButton(
          text: LocaleKeys.go_to_home.tr(),
          onPressed: () => context.pushNamed(Routes.layout),
        ),
      ],
    );
  }
}
