import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
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
                height: height * 0.63,
                child: Image.asset(AppAssets.authBackImage, fit: BoxFit.fill),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.1),
                  Center(
                    child: Image.asset(
                      AppAssets.logoTransparent,
                      width: width * 0.8,
                    ),
                  ),
                  const Spacer(),
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
    );
  }
}
