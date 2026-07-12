import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/themes/app_text_styles.dart';

class GiftPickerButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const GiftPickerButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.sw(16),
          vertical: context.sh(14),
        ),
        decoration: BoxDecoration(
          color: context.colors.cardBackGround,
          border: Border.all(color: context.colors.borderSecondary),
          borderRadius: BorderRadius.circular(context.sw(12)),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.regular14.copyWith(
                fontSize: context.sw(14),
                color: context.colors.textPrimary,
              ),
            ),
            const Spacer(),
            SvgPicture.asset(
              icon,
              height: context.sw(20),
              colorFilter: ColorFilter.mode(
                context.colors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
