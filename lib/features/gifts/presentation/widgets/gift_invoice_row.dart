import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';

class GiftInvoiceRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;

  const GiftInvoiceRow({
    super.key,
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isTotal ? AppTextStyles.bold16 : AppTextStyles.regular14)
              .copyWith(
                fontSize: isTotal ? context.sw(16) : context.sw(14),
                color: isTotal
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
        ),
        Row(
          children: [
            Text(
              amount.toStringAsFixed(2),
              style: (isTotal ? AppTextStyles.bold16 : AppTextStyles.medium14)
                  .copyWith(
                    fontSize: isTotal ? context.sw(16) : context.sw(14),
                    color: isTotal
                        ? context.colors.textPrimary
                        : context.colors.textSecondary,
                  ),
            ),
            SizedBox(width: context.sw(4)),
            SvgPicture.asset(
              AppAssets.currency,
              width: isTotal ? context.sw(18) : context.sw(14),
              colorFilter: ColorFilter.mode(
                isTotal
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
