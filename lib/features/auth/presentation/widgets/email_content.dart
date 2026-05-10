import 'package:aqua_go/core/components/custom_button.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/themes/app_colors_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/components/custom_text_field.dart';
import '../../../../core/route/routes.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../generated/locale_keys.g.dart';
import '../views/email_otp_view.dart';

class EmailContent extends StatefulWidget {
  const EmailContent({super.key});

  @override
  State<EmailContent> createState() => _EmailContentState();
}

class _EmailContentState extends State<EmailContent> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final text = _emailController.text;
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    setState(() {
      _isEmailValid = regex.hasMatch(text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.43,
      decoration: BoxDecoration(
        color: darkAppColors.themeColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.auth_add_email.tr(),
              style: AppTextStyles.semiBold24,
            ),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.auth_send_verification_mail.tr(),
              style: AppTextStyles.regular16.copyWith(
                color: darkAppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _emailController,
              label: LocaleKeys.auth_email_address.tr(),
              hint: LocaleKeys.auth_enter_email.tr(),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(AppAssets.mail),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: _isEmailValid
                  ? () {
                      context.pushNamed(
                        Routes.emailOtp,
                        arguments: EmailOtpArgs(email: _emailController.text),
                      );
                    }
                  : null,
              text: LocaleKeys.proceed.tr(),
              enabled: _isEmailValid,
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: () {
                context.pop();
              },
              text: LocaleKeys.auth_back_to_profile.tr(),
              textColor: context.colors.primary,
              color: Colors.transparent,
              enabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
