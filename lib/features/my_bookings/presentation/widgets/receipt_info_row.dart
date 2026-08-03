import 'package:flutter/material.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';

class ReceiptInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ReceiptInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final double swVal = context.sw(12);

    final labelWidget = Expanded(
      flex: 3,
      child: Text(
        label,
        style: AppTextStyles.regular14.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );

    final dividerWidget = Container(
      height: 18,
      width: 1,
      color: context.colors.borderSecondary.withValues(alpha: 0.3),
      margin: EdgeInsets.symmetric(horizontal: swVal),
    );

    final valueWidget = Expanded(
      flex: 6,
      child: Text(
        value,
        style: AppTextStyles.medium14.copyWith(
          color: context.colors.textPrimary,
        ),
        textAlign: TextAlign.end,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [labelWidget, dividerWidget, valueWidget],
    );
  }
}
