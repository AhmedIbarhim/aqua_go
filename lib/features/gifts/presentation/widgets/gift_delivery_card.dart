import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/components/custom_radio_widget.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

class GiftDeliveryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const GiftDeliveryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.sw(8),
          vertical: context.sh(8),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.brandHover.withValues(alpha: 0.15)
              : context.colors.cardBackGround,
          borderRadius: BorderRadius.circular(context.sw(12)),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.borderSecondary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.sw(8)),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primary.withValues(alpha: 0.15)
                    : context.colors.defaultSubtle,
                borderRadius: BorderRadius.circular(context.sw(8)),
              ),
              child: SvgPicture.asset(
                icon == Icons.calendar_today_outlined
                    ? AppAssets.giftSendNow
                    : AppAssets.giftSendLater,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? context.colors.primary
                      : context.colors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: context.sw(12)),
            Text(
              title,
              style: AppTextStyles.medium14.copyWith(
                fontSize: context.sw(14),
                color: isSelected
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
            ),
            const Spacer(),
            CustomRadioWidget(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}
