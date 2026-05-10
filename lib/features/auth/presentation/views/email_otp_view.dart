import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg_flutter.dart';
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
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: height * 0.63,

              child: SvgPicture.asset(
                AppAssets.authBackImage,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            top: height * 0.12,
            left: 0,
            right: 0,

            child: SizedBox(
              width: 100,
              child: Center(child: Image.asset(AppAssets.logoTransparent)),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: EmailOtpContent(email: email),
            // child: ErrorContent(),
          ),
        ],
      ),
    );
  }
}
