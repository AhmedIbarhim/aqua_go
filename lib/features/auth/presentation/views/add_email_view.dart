import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:aqua_go/features/auth/presentation/widgets/email_content.dart';
import 'package:flutter/material.dart';

class AddEmailView extends StatelessWidget {
  const AddEmailView({super.key});

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
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: EmailContent(),
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
