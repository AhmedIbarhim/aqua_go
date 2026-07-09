import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/locale_keys.g.dart';

class EmptyGiftsWidget extends StatelessWidget {
  final bool isSentTab;
  final VoidCallback onSendGiftPressed;

  const EmptyGiftsWidget({
    super.key,
    required this.isSentTab,
    required this.onSendGiftPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String title = LocaleKeys.gifts_empty_title.tr(context: context);
    final String description = isSentTab
        ? LocaleKeys.gifts_empty_sent_desc.tr(context: context)
        : LocaleKeys.gifts_empty_received_desc.tr(context: context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppAssets.emptyGift, width: 160, height: 160),
          const SizedBox(height: 32),
          Text(
            title,
            style: AppTextStyles.semiBold18.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTextStyles.regular14.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (isSentTab)
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.6,
              child: CustomButton(
                text: LocaleKeys.gifts_empty_send_now.tr(context: context),
                onPressed: onSendGiftPressed,
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
