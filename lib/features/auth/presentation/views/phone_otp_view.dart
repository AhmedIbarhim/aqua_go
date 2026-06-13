import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/auth/presentation/controllers/auth_cubit/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../generated/locale_keys.g.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/phone_otp_content.dart';

class PhoneOtpArgs {
  final String phoneNumber;
  PhoneOtpArgs({required this.phoneNumber});
}

class PhoneOtpView extends StatelessWidget {
  const PhoneOtpView({super.key, required this.phoneNumber});
  final String phoneNumber;

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
            if (state is LoginSuccess) {
              context.showSuccessSnackBar(
                LocaleKeys.snackbar_login_success.tr(),
              );
            }
          }
        },
        child: AuthScaffold(content: PhoneOtpContent(phoneNumber: phoneNumber)),
      ),
    );
  }
}
