import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/custom_text_form_field.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../generated/locale_keys.g.dart';

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
    // KSA mobile: starts with 5 and has 9 digits total
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
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.43,
      decoration: BoxDecoration(
        color: darkAppColors.themeColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.auth_login.tr(), style: AppTextStyles.semiBold24),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.auth_send_verification_code.tr(),
              style: AppTextStyles.regular16.copyWith(
                color: darkAppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 36),
            Text(
              LocaleKeys.auth_phone_number.tr(),
              style: AppTextStyles.regular14,
            ),
            const SizedBox(height: 16),
            CustomPhoneTextField(controller: _phoneController),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: _isPhoneValid
                  ? () {
                      Navigator.pushNamed(
                        context,
                        Routes.phoneOtp,
                        arguments: _phoneController.text,
                      );
                    }
                  : null,
              text: LocaleKeys.auth_login.tr(),
              enabled: _isPhoneValid,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: LocaleKeys.auth_continue_as_guest.tr(),
              color: darkAppColors.themeColor,
              textColor: context.colors.primary,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
