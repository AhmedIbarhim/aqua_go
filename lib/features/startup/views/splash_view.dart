import 'package:aqua_go/core/extentions/context_extentions.dart';
import 'package:aqua_go/core/utils/app_assets.dart';
import 'package:flutter/material.dart';

import '../../../core/config/local_storage/secure_storage.dart';
import '../../../core/config/local_storage/shared_prefs.dart';
import '../../../core/constants.dart';
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
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final token = await SecureStorage.getSecuredString(kAccessToken);
    final isGuest = CacheClient.getBool(kIsGuest);
    if (!mounted) return;

    if ((token != null && token.isNotEmpty) || isGuest) {
      context.pushReplacementNamed(Routes.layout);
    } else {
      final isNotFirstUse = CacheClient.getBool(kNotFirstUse);
      if (isNotFirstUse) {
        context.pushReplacementNamed(Routes.login);
      } else {
        context.pushReplacementNamed(Routes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.splashColor,
      body: Center(child: Image.asset(AppAssets.logo)),
    );
  }
}
