import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../themes/app_colors_extension.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    required this.text,
    this.enabled = true,
    this.color,
    this.textColor = Colors.black,
    this.borderColor,
    this.preWidget,
    this.postWidget,
  });
  final void Function()? onPressed;
  final String text;
  final bool enabled;
  final Color? color;
  final Color textColor;
  final Color? borderColor;
  final Widget? preWidget;
  final Widget? postWidget;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: enabled ? onPressed : null,
      color: color ?? context.colors.primary,
      disabledColor: context.colors.brandSubtle,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: enabled
              ? (borderColor ?? context.colors.primary)
              : context.colors.brandSubtle,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      textColor: enabled ? textColor : context.colors.contentDisabled,

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
