import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';

import '../../../core/route/routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      context.pushReplacementNamed(Routes.onboarding);
      // context.pushReplacementNamed(Routes.layout);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.splashColor,
      body: Center(child: Image.asset(AppAssets.logo)),
    );
  }
}
