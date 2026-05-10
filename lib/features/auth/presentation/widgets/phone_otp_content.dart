import 'dart:async';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/custom_otp_field.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_colors_extension.dart';
import '../../../../core/themes/app_text_styles.dart';

class PhoneOtpContent extends StatefulWidget {
  const PhoneOtpContent({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<PhoneOtpContent> createState() => _PhoneOtpContentState();
}

class _PhoneOtpContentState extends State<PhoneOtpContent> {
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
      decoration: BoxDecoration(
        color: darkAppColors.themeColor,
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
                  color: darkAppColors.textPrimary,
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
                  color: darkAppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                widget.phoneNumber,
                style: AppTextStyles.regular16.copyWith(
                  color: darkAppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          CustomOtpFields(
            controllers: _controllers,
            focusNodes: _focusNodes,
            onChanged: (value) => setState(() {}),
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
                      color: context.colors.primary,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      LocaleKeys.auth_resend_code.tr(),
                      style: AppTextStyles.regular16.copyWith(
                        color: darkAppColors.contentSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timerText,
                      style: AppTextStyles.regular16.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
