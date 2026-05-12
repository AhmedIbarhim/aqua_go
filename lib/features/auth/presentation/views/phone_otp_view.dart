import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
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
                height: height * 0.65,
                child: Image.asset(AppAssets.authBackImage, fit: BoxFit.fill),
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
                    child: PhoneOtpContent(phoneNumber: phoneNumber),
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
