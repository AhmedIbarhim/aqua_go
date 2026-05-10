import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg_flutter.dart';
import '../widgets/phone_otp_content.dart';

class PhoneOtpView extends StatelessWidget {
  const PhoneOtpView({super.key, required this.phoneNumber});
  final String phoneNumber;

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
            child: PhoneOtpContent(phoneNumber: phoneNumber),
            // child: ErrorContent(),
          ),
        ],
      ),
    );
  }
}
