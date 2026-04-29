import 'dart:ui' as ui;
import 'dart:async';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';

class OtpContent extends StatefulWidget {
  const OtpContent({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<OtpContent> createState() => _OtpContentState();
}

class _OtpContentState extends State<OtpContent> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  Timer? _timer;
  int _start = 60;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (index) => TextEditingController());
    _focusNodes = List.generate(4, (index) => FocusNode());
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String get _timerText {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool get _isOtpComplete => _controllers.every((c) => c.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: height * 0.43,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.auth_verify_phone.tr(),
                style: AppTextStyles.semiBold24.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.auth_enter_verification_code.tr(),
                style: AppTextStyles.regular16.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                widget.phoneNumber,
                style: AppTextStyles.regular16.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _buildOtpField(index)),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: LocaleKeys.auth_verify.tr(),
            onPressed: _isOtpComplete
                ? () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.layout,
                      (route) => false,
                    );
                  }
                : null,
            enabled: _isOtpComplete,
          ),
          const SizedBox(height: 48),
          _start == 0
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _start = 60;
                    });
                    startTimer();
                  },
                  child: Text(
                    LocaleKeys.auth_resend_code_button.tr(),
                    style: AppTextStyles.regular16.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      LocaleKeys.auth_resend_code.tr(),
                      style: AppTextStyles.regular16.copyWith(
                        color: AppColors.contentSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timerText,
                      style: AppTextStyles.regular16.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color:
            _controllers[index].text.isNotEmpty || _focusNodes[index].hasFocus
            ? AppColors.brandHover
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _controllers[index].text.isNotEmpty || _focusNodes[index].hasFocus
              ? AppColors.primary
              : AppColors.borderSecondary,
          width:
              _controllers[index].text.isNotEmpty || _focusNodes[index].hasFocus
              ? 1.5
              : 1,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        onTapOutside: (event) {
          _focusNodes[index].unfocus();
        },
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        onTap: () {
          // Ensure focus goes to the first empty field
          for (int i = 0; i < index; i++) {
            if (_controllers[i].text.isEmpty) {
              _focusNodes[i].requestFocus();
              return;
            }
          }
        },
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        style: AppTextStyles.semiBold32.copyWith(
          color: _controllers[index].text.isNotEmpty
              ? AppColors.textPrimary
              : AppColors.contentDisabled,
        ),
        decoration: InputDecoration(
          hintText: '_',
          hintStyle: AppTextStyles.regular32.copyWith(
            color: AppColors.contentDisabled,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        showCursor: false,
      ),
    );
  }
}
