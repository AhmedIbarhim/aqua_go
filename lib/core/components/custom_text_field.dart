import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extentions/context_extentions.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isRequired;
  final TextInputType? keyboardType;
  final bool? mustCapitalize;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final Color? fillColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextStyle? style;
  final int? maxLines;
  final int? minLines;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isRequired = false,
    this.keyboardType,
    this.mustCapitalize,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.fillColor,
    this.prefixIcon,
    this.suffixIcon,
    this.style,
    this.maxLines,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.sizeOf(context).height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (isRequired)
              Text(
                "* ",
                style: AppTextStyles.regular14.copyWith(
                  color: context.colors.error,
                ),
              ),
            Text(
              label,
              style: AppTextStyles.medium14.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: height * 0.055,
          child: TextField(
            onTap: onTap,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            readOnly: readOnly,
            enabled: enabled,
            textCapitalization: mustCapitalize == true
                ? TextCapitalization.characters
                : TextCapitalization.none,
            inputFormatters: mustCapitalize == true
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                        text: newValue.text.toUpperCase(),
                      );
                    }),
                  ]
                : null,
            controller: controller,
            textAlign: TextAlign.right,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: keyboardType,
            style:
                style ??
                AppTextStyles.regular14.copyWith(
                  color: context.colors.textPrimary,
                ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.regular14.copyWith(
                color: context.colors.contentDisabled,
              ),
              filled: true,
              fillColor: fillColor ?? context.colors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.borderSecondary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.borderSecondary),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.borderSecondary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.colors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
