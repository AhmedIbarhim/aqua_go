import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    required this.text,
    this.enabled = true,
    this.color = AppColors.primary,
    this.textColor = AppColors.textDark,
    this.preWidget,
    this.postWidget,
  });
  final void Function()? onPressed;
  final String text;
  final bool enabled;
  final Color color;
  final Color textColor;
  final Widget? preWidget;
  final Widget? postWidget;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: enabled ? onPressed : null,
      color: color,
      disabledColor: AppColors.brandSubtle,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: enabled ? AppColors.primary : AppColors.brandSubtle,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      textColor: enabled ? textColor : AppColors.contentDisabled,

      minWidth: double.infinity,
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          if (preWidget != null) preWidget!,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(text, style: AppTextStyles.regular16),
          ),
          if (postWidget != null) postWidget!,
        ],
      ),
    );
  }
}
