import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/auth/presentation/controllers/auth_cubit/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/email_otp_content.dart';

class EmailOtpArgs {
  final String email;
  final String otpSessionId;
  EmailOtpArgs({required this.email, required this.otpSessionId});
}

class EmailOtpView extends StatelessWidget {
  const EmailOtpView({
    super.key,
    required this.email,
    required this.otpSessionId,
  });
  final String email;
  final String otpSessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<AuthCubit>(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            context.showLoadingOverlay();
          } else {
            context.hideLoadingOverlay();
          }
          if (state is LoginSuccess) {
            context.showSuccessSnackBar(
              LocaleKeys.snackbar_update_email_success.tr(),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.layout,
              (route) => false,
            );
          } else if (state is LoginError) {
            context.showErrorSnackBar(state.message);
          }
        },
        child: AuthScaffold(
          content: EmailOtpContent(email: email, otpSessionId: otpSessionId),
        ),
      ),
    );
  }
}
