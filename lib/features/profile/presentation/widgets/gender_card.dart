import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/extentions/context_extentions.dart';

class GenderCard extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final bool isEditing;
  final double height;
  final double iconSize;
  final VoidCallback? onTap;

  const GenderCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isEditing,
    required this.height,
    required this.iconSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    double iconOpacity;

    if (isEditing) {
      if (isSelected) {
        bgColor = context.colors.brandHover;
        borderColor = context.colors.primary;
        textColor = context.colors.textPrimary;
        iconOpacity = 1.0;
      } else {
        bgColor = context.colors.background;
        borderColor = context.colors.borderSecondary;
        textColor = context.colors.contentSecondaryLight;
        iconOpacity = 1.0;
      }
    } else {
      if (isSelected) {
        bgColor = context.colors.cardBackGround;
        borderColor = context.colors.borderSecondary;
        textColor = context.colors.textSecondary;
        iconOpacity = 1.0;
      } else {
        bgColor = context.colors.background;
        borderColor = context.colors.defaultSubtle;
        textColor = context.colors.contentDisabled;
        iconOpacity = 0.5;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: iconOpacity,
              child: SvgPicture.asset(icon, width: iconSize, height: iconSize),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: (isSelected && isEditing) || (isSelected && !isEditing)
                  ? AppTextStyles.medium18.copyWith(color: textColor)
                  : AppTextStyles.regular18.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
