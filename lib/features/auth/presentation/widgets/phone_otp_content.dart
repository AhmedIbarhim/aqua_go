import 'dart:async';
import 'package:aqua_go/features/auth/controllers/auth_cubit/auth_cubit.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/components/custom_button.dart';
import '../../../../core/components/custom_otp_field.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_colors.dart';
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
  String? _otpSessionId;
  String? _errorMessage;

  bool _isOtpValidationError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('timeout') ||
        msg.contains('internet') ||
        msg.contains('connection') ||
        msg.contains('server error') ||
        msg.contains('try again later') ||
        msg.contains('canceled') ||
        msg.contains('unexpected') ||
        msg.contains('oops')) {
      return false;
    }
    return true;
  }

  bool get _isExpiredError =>
      _errorMessage != null &&
      (_errorMessage!.toLowerCase().contains('expire') ||
          _errorMessage!.contains('انتهت') ||
          _errorMessage!.contains('منتهي'));

  String get _displayError {
    if (_errorMessage == null) return '';
    if (_isExpiredError) {
      return LocaleKeys.auth_otp_expired_message.tr();
    }
    return LocaleKeys.auth_otp_invalid_message.tr();
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (index) => TextEditingController());
    _focusNodes = List.generate(4, (index) => FocusNode());
    startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().login(widget.phoneNumber);
    });
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
    final height = MediaQuery.sizeOf(context).height;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpSent) {
          _otpSessionId = state.otpSessionId;
          context.showSuccessSnackBar(LocaleKeys.auth_otp_code_sent.tr());
        } else if (state is LoginSuccess) {
          // Check if user has name (complete data)
          if (state.user.name == null || state.user.name!.isEmpty) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.profileData,
              (route) => false,
              arguments: true, // isFirstTime = true
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.layout,
              (route) => false,
            );
          }
        } else if (state is LoginError) {
          context.showErrorSnackBar(state.message);
          setState(() {
            if (_isOtpValidationError(state.message)) {
              _errorMessage = state.message;
            } else {
              _errorMessage = null;
            }
          });
        }
      },
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: height * 0.02,
          ),
          decoration: BoxDecoration(
            color: darkAppColors.themeColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.auth_verify_phone.tr(),
                  style: AppTextStyles.semiBold24.copyWith(
                    color: darkAppColors.textPrimary,
                  ),
                ),
                SizedBox(height: height * 0.02),
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
                    Expanded(
                      child: Text(
                        widget.phoneNumber,
                        style: AppTextStyles.regular16.copyWith(
                          color: darkAppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.03),
                CustomOtpFields(
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  hasError: _errorMessage != null,
                  onChanged: (value) {
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: height * 0.015),
                  Center(
                    child: Text(
                      _displayError,
                      style: AppTextStyles.regular16.copyWith(
                        color: context.colors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                SizedBox(height: height * 0.03),
                CustomButton(
                  text: LocaleKeys.auth_verify.tr(),
                  // isLoading: state is LoginLoading,
                  onPressed:
                      _isOtpComplete &&
                          _otpSessionId != null &&
                          _errorMessage == null
                      ? () {
                          final otp = _controllers.map((c) => c.text).join();
                          context.read<AuthCubit>().verifyOtp(
                            phone: widget.phoneNumber,
                            otpSessionId: _otpSessionId!,
                            otp: otp,
                          );
                        }
                      : null,
                  enabled:
                      _isOtpComplete &&
                      _otpSessionId != null &&
                      _errorMessage == null,
                ),
                SizedBox(height: height * 0.025),
                Center(
                  child: _start == 0
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _start = 60;
                            });
                            startTimer();
                            context.read<AuthCubit>().login(widget.phoneNumber);
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
                ),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        );
      },
    );
  }
}
