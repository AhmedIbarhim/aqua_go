import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';

import '../widgets/login_content.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

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
                  SizedBox(height: height * 0.1),
                  Center(
                    child: Image.asset(
                      AppAssets.logoTransparent,
                      width: width * 0.8,
                    ),
                  ),
                  const Spacer(),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: LoginContent(),
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
