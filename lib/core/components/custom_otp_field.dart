import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extentions/context_extentions.dart';
import '../themes/app_text_styles.dart';

class CustomOtpFields extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String)? onChanged;
  final bool hasError;

  const CustomOtpFields({
    super.key,
    required this.controllers,
    required this.focusNodes,
    this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controllers.length,
          (index) => _SingleOtpField(
            index: index,
            controllers: controllers,
            focusNodes: focusNodes,
            hasError: hasError,
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < controllers.length - 1) {
                  focusNodes[index + 1].requestFocus();
                } else {
                  focusNodes[index].unfocus();
                }
              } else if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }
              onChanged?.call(value);
            },
          ),
        ),
      ),
    );
  }
}

class _SingleOtpField extends StatefulWidget {
  final int index;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String) onChanged;
  final bool hasError;

  const _SingleOtpField({
    required this.index,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.hasError,
  });

  @override
  State<_SingleOtpField> createState() => _SingleOtpFieldState();
}

class _SingleOtpFieldState extends State<_SingleOtpField> {
  @override
  void initState() {
    super.initState();
    widget.focusNodes[widget.index].addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNodes[widget.index].removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final colors = context.colors;
    final controller = widget.controllers[widget.index];
    final focusNode = widget.focusNodes[widget.index];
    final bool isFocusedOrNotEmpty =
        controller.text.isNotEmpty || focusNode.hasFocus;

    Color borderColor;
    double borderWidth;
    if (widget.hasError) {
      borderColor = context.colors.error.withValues(alpha: 0.2);
      borderWidth = 1.5;
    } else if (isFocusedOrNotEmpty) {
      borderColor = colors.primary;
      borderWidth = 1.5;
    } else {
      borderColor = colors.borderSecondary;
      borderWidth = 1;
    }

    return Container(
      width: screenHeight * 0.07,
      height: screenHeight * 0.07,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isFocusedOrNotEmpty ? colors.brandHover : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      alignment: Alignment.center,
      child: TextField(
        onTapOutside: (event) {
          focusNode.unfocus();
        },
        controller: controller,
        focusNode: focusNode,
        onTap: () {
          for (int i = 0; i < widget.index; i++) {
            if (widget.controllers[i].text.isEmpty) {
              widget.focusNodes[i].requestFocus();
              return;
            }
          }
        },
        onChanged: widget.onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        style: AppTextStyles.semiBold32.copyWith(
          color: controller.text.isNotEmpty
              ? colors.textPrimary
              : colors.contentDisabled,
        ),
        decoration: InputDecoration(
          hintText: '_',
          hintStyle: AppTextStyles.regular32.copyWith(
            color: colors.contentDisabled,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        showCursor: false,
      ),
    );
  }
}
