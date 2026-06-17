import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/themes/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/custom_text_form_field.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
import '../controllers/auth_cubit/auth_cubit.dart';
import '../views/phone_otp_view.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  void _validatePhone() {
    final text = _phoneController.text;
    final regex = RegExp(r'^5[0-9]{8}$');
    setState(() {
      _isPhoneValid = regex.hasMatch(text);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LoginLoading) {
          context.showLoadingOverlay();
        } else {
          context.hideLoadingOverlay();
        }
        if (state is OtpSent) {
          context.pushNamed(
            Routes.phoneOtp,
            arguments: PhoneOtpArgs(
              phoneNumber: '+966${_phoneController.text}',
              otpSessionId: state.otpSessionId,
            ),
          );
        } else if (state is LoginError) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: darkAppColors.themeColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: height * 0.02,
                bottom:
                    height * 0.02 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.auth_login.tr(),
                    style: AppTextStyles.semiBold24,
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    LocaleKeys.auth_send_verification_code.tr(),
                    style: AppTextStyles.regular16.copyWith(
                      color: darkAppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    LocaleKeys.auth_phone_number.tr(),
                    style: AppTextStyles.regular14,
                  ),
                  SizedBox(height: height * 0.01),
                  CustomPhoneTextField(controller: _phoneController),
                  SizedBox(height: height * 0.02),
                  CustomButton(
                    onPressed: _isPhoneValid
                        ? () {
                            context.read<AuthCubit>().login(
                              '+966${_phoneController.text}',
                            );
                          }
                        : null,
                    text: LocaleKeys.auth_login.tr(),
                    enabled: _isPhoneValid,
                  ),
                  SizedBox(height: height * 0.01),
                  CustomButton(
                    text: LocaleKeys.auth_continue_as_guest.tr(),
                    color: darkAppColors.themeColor,
                    textColor: context.colors.primary,
                    onPressed: () {
                      context.pushReplacementNamed(Routes.layout);
                    },
                  ),
                  SizedBox(height: height * 0.02),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
