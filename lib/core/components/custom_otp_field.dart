import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../extentions/context_extentions.dart';
import '../themes/app_text_styles.dart';

class CustomOtpFields extends StatefulWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String)? onChanged;
  final bool hasError;
  final Color? textColor;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? focusedFillColor;
  final Color? disabledColor;
  final Color? errorColor;

  const CustomOtpFields({
    super.key,
    required this.controllers,
    required this.focusNodes,
    this.onChanged,
    this.hasError = false,
    this.textColor,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.focusedFillColor,
    this.disabledColor,
    this.errorColor,
  });

  @override
  State<CustomOtpFields> createState() => _CustomOtpFieldsState();
}

class _CustomOtpFieldsState extends State<CustomOtpFields> {
  late final TextEditingController _pinputController;
  late final FocusNode _pinputFocusNode;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Combine initial values from parent controllers
    final initialText = widget.controllers.map((c) => c.text).join();
    _pinputController = TextEditingController(text: initialText);
    _pinputFocusNode = FocusNode();

    // Synchronize pinput changes back to parent controllers
    _pinputController.addListener(_onPinputChange);

    // Listen to parent controllers for any programmatic changes (like clearing)
    for (var controller in widget.controllers) {
      controller.addListener(_onParentControllerChange);
    }

    // Listen to parent focusNodes
    for (var node in widget.focusNodes) {
      node.addListener(_onParentFocusChange);
    }

    // Focus if any parent node is focused
    if (widget.focusNodes.any((node) => node.hasFocus)) {
      _pinputFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pinputController.removeListener(_onPinputChange);
    for (var controller in widget.controllers) {
      controller.removeListener(_onParentControllerChange);
    }
    for (var node in widget.focusNodes) {
      node.removeListener(_onParentFocusChange);
    }
    _pinputController.dispose();
    _pinputFocusNode.dispose();
    super.dispose();
  }

  void _onPinputChange() {
    if (_isDisposed) return;
    final text = _pinputController.text;

    // Check if anything actually changed in parent controllers to avoid loop
    bool hasChanged = false;
    for (int i = 0; i < widget.controllers.length; i++) {
      final char = i < text.length ? text[i] : '';
      if (widget.controllers[i].text != char) {
        widget.controllers[i].text = char;
        hasChanged = true;
      }
    }

    if (hasChanged) {
      widget.onChanged?.call(text);
    }
  }

  void _onParentControllerChange() {
    if (_isDisposed) return;
    final combined = widget.controllers.map((c) => c.text).join();
    if (_pinputController.text != combined) {
      _pinputController.text = combined;
    }
  }

  void _onParentFocusChange() {
    if (_isDisposed) return;
    final anyHasFocus = widget.focusNodes.any((node) => node.hasFocus);
    if (anyHasFocus && !_pinputFocusNode.hasFocus) {
      _pinputFocusNode.requestFocus();
    } else if (!anyHasFocus && _pinputFocusNode.hasFocus) {
      _pinputFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Define base PinTheme
    final defaultPinTheme = PinTheme(
      width: screenHeight * 0.07,
      height: screenHeight * 0.07,
      textStyle: AppTextStyles.semiBold32.copyWith(
        color: widget.textColor ?? context.colors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: widget.fillColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.borderColor ?? context.colors.borderSecondary,
          width: 1,
        ),
      ),
    );

    // Focused theme: primary border, brandHover background
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: widget.focusedFillColor ?? context.colors.brandHover,
        border: Border.all(
          color: widget.focusedBorderColor ?? context.colors.primary,
          width: 1.5,
        ),
      ),
    );

    // Submitted theme matches focused theme in background color, but uses primary border or borderSecondary
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: widget.focusedFillColor ?? context.colors.brandHover,
        border: Border.all(
          color: widget.focusedBorderColor ?? context.colors.primary,
          width: 1.5,
        ),
      ),
    );

    // Error theme: error border color
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: _pinputFocusNode.hasFocus || _pinputController.text.isNotEmpty
            ? (widget.focusedFillColor ?? context.colors.brandHover)
            : (widget.fillColor ?? Colors.transparent),
        border: Border.all(
          color: (widget.errorColor ?? context.colors.error).withValues(
            alpha: 0.2,
          ),
          width: 1.5,
        ),
      ),
    );

    return Center(
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Pinput(
          length: widget.controllers.length,
          controller: _pinputController,
          focusNode: _pinputFocusNode,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          errorPinTheme: errorPinTheme,
          forceErrorState: widget.hasError,
          separatorBuilder: (index) => const SizedBox(width: 12),
          mainAxisAlignment: MainAxisAlignment.center,
          preFilledWidget: Text(
            '_',
            style: AppTextStyles.regular32.copyWith(
              color: widget.disabledColor ?? context.colors.contentDisabled,
            ),
          ),
          showCursor: false,
        ),
      ),
    );
  }
}
