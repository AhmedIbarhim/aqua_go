import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/route/routes.dart';
import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/features/auth/controllers/auth_cubit/auth_cubit.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/email_otp_content.dart';

class EmailOtpArgs {
  final String email;
  EmailOtpArgs({required this.email});
}

class EmailOtpView extends StatelessWidget {
  const EmailOtpView({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
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
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.layout,
              (route) => false,
            );
          } else if (state is LoginError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body: SingleChildScrollView(
            child: SizedBox(
              height: height,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: height * 0.65,
                    child: Image.asset(
                      AppAssets.authBackImage,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: Center(
                            child: Image.asset(
                              AppAssets.logoTransparent,
                              width: width * 0.8,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: EmailOtpContent(email: email),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
