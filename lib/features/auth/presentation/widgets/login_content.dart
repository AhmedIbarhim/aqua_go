import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/custom_text_form_field.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkAppColors.themeColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: height * 0.02),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LocaleKeys.auth_login.tr(), style: AppTextStyles.semiBold24),
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
                        Navigator.pushNamed(
                          context,
                          Routes.phoneOtp,
                          arguments: PhoneOtpArgs(
                            phoneNumber: _phoneController.text,
                          ),
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
                onPressed: () {},
              ),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
