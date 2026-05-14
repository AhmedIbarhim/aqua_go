import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/utils/app_assets.dart';

class EmptyNotificationsWidget extends StatelessWidget {
  const EmptyNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(AppAssets.notificationsEmpty),
        const SizedBox(height: 24),
        Text(
          LocaleKeys.notifications_no_notifications.tr(),
          style: AppTextStyles.semiBold18,
        ),
        const SizedBox(height: 16),
        Text(
          LocaleKeys.notifications_no_notification_desc.tr(),
          style: AppTextStyles.regular16.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
