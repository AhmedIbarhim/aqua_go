import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../extentions/context_extentions.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    required this.text,
    this.enabled = true,
    this.color,
    this.disabledColor,
    this.textColor = Colors.black,
    this.disabledTextColor,
    this.borderColor,
    this.disabledBorderColor,
    this.preWidget,
    this.postWidget,
  });
  final void Function()? onPressed;
  final String text;
  final bool enabled;
  final Color? color;
  final Color? disabledColor;
  final Color textColor;
  final Color? disabledTextColor;
  final Color? borderColor;
  final Color? disabledBorderColor;
  final Widget? preWidget;
  final Widget? postWidget;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: enabled ? onPressed : null,
      color: color ?? context.colors.primary,
      disabledColor: disabledColor ?? context.colors.contentDisabled,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: enabled
              ? (borderColor ?? color ?? context.colors.primary)
              : (disabledBorderColor ?? context.colors.contentTertiary),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      textColor: enabled
          ? textColor
          : (disabledTextColor ?? context.colors.textSecondary),
      elevation: 0,
      minWidth: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.055,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          ?preWidget,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(text, style: AppTextStyles.regular16),
          ),
          ?postWidget,
        ],
      ),
    );
  }
}
