import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svg_flutter/svg.dart';

import '../themes/app_colors_extension.dart';
import '../themes/app_text_styles.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.controller,
    required this.label,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines,
    this.minLines,
    this.obscureText = false,
    this.onSaved,
  });

  final String label;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final int? minLines;
  final bool obscureText;
  final TextEditingController? controller;
  final void Function(String?)? onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onSaved: onSaved,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },

      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return 'هذا الحقل مطلوب';
      //   }
      //   return null;
      // },
      keyboardType: keyboardType,
      decoration: InputDecoration(
        // filled: true,
        // fillColor: AppColors.black,
        border: buildBorder(),
        enabledBorder: buildBorder(),
        labelText: label,
        labelStyle: AppTextStyles.regular12,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
    );
  }

  OutlineInputBorder buildBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );
  }
}

class CustomPhoneTextField extends StatefulWidget {
  const CustomPhoneTextField({
    super.key,
    this.controller,
    this.onSaved,
    this.label = "رقم التليفون",
  });

  final TextEditingController? controller;
  final void Function(String?)? onSaved;
  final String label;

  @override
  State<CustomPhoneTextField> createState() => _CustomPhoneTextFieldState();
}

class _CustomPhoneTextFieldState extends State<CustomPhoneTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border.all(color: context.colors.borderSecondary),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SvgPicture.asset(
                        AppAssets.ksaFlag,
                        width: 16,
                        height: 16,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "+966",
                    style: AppTextStyles.regular16.copyWith(
                      color: context.colors.background,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                validator: (value) {
                  final fullValue = "+966${value ?? ""}";
                  if (value!.isEmpty) {
                    return "context.locale.pleaseFillAllFields";
                  } else if (fullValue.length < 13) {
                    return "context.locale.pleaseEnterCorrectPhoneNumber";
                  }
                  return null;
                },

                onSaved: widget.onSaved,
                style: AppTextStyles.medium16.copyWith(
                  color: context.colors.contentSecondaryLight,
                ),
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  LengthLimitingTextInputFormatter(9),
                ],
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
