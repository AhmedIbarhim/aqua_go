import 'package:aqua_go/features/auth/presentation/views/login_view.dart';
import 'package:aqua_go/features/layout/presentation/views/main_layout.dart';
import 'package:aqua_go/features/startup/views/onboarding_view.dart';
import 'package:aqua_go/features/startup/views/splash_view.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/views/otp_view.dart';
import 'routes.dart';

abstract class AppRouter {
  static Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());

      case Routes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingView());

      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case Routes.otp:
        return MaterialPageRoute(
          builder: (_) => OtpView(phoneNumber: settings.arguments as String),
        );

      case Routes.layout:
        return MaterialPageRoute(builder: (_) => const MainLayout());

      default:
        return MaterialPageRoute(builder: (_) => const Placeholder());
    }
  }
}
