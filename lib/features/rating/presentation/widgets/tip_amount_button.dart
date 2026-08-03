import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';

class TipAmountButton extends StatelessWidget {
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;

  const TipAmountButton({
    super.key,
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.brandHover
              : context.colors.cardBackGround,
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.borderSecondary,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            context.isEn
                ? "${amount.toStringAsFixed(2)} SAR"
                : "${amount.toStringAsFixed(2)} ﷼",
            style: AppTextStyles.medium14.copyWith(
              color: isSelected
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class OtherAmountButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const OtherAmountButton({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.brandHover
              : context.colors.cardBackGround,
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.borderSecondary,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            LocaleKeys.bookings_other_value.tr(context: context),
            style: AppTextStyles.medium14.copyWith(
              color: isSelected
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
