import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:aqua_go/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../generated/locale_keys.g.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isRequired;
  final TextInputType? keyboardType;
  final bool? mustCapitalize;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isRequired = false,
    this.keyboardType,
    this.mustCapitalize,
  });

  @override
  Widget build(BuildContext context) {
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
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "LocaleKeys.required_field.tr()";
            }
            return null;
          },
          textCapitalization: mustCapitalize == true
              ? TextCapitalization.characters
              : TextCapitalization.none,
          inputFormatters: mustCapitalize == true
              ? [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]')),

                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(text: newValue.text.toUpperCase());
                  }),
                ]
              : null,
          controller: controller,
          textAlign: TextAlign.right,
          keyboardType: keyboardType,
          style: AppTextStyles.regular14.copyWith(
            color: context.colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.regular14.copyWith(
              color: context.colors.contentDisabled,
            ),
            filled: true,
            fillColor: context.colors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.borderSecondary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.borderSecondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
