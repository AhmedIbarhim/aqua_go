import 'package:flutter/material.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/otp_view.dart';
import '../../features/home/presentation/data/models/offer_model.dart';
import '../../features/home/presentation/data/models/package_model.dart';
import '../../features/home/presentation/views/offers_view.dart';
import '../../features/home/presentation/views/packages_view.dart';
import '../../features/layout/presentation/views/main_layout.dart';
import '../../features/startup/views/onboarding_view.dart';
import '../../features/startup/views/splash_view.dart';
import '../../features/notifications/presentation/views/notification_view.dart';
import '../../features/profile/presentation/views/settings_view.dart';
import '../../features/my_cars/presentation/views/add_car_view.dart';
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

      case Routes.offers:
        return MaterialPageRoute(
          builder: (_) =>
              OffersView(offers: settings.arguments as List<OfferModel>),
        );

      case Routes.packages:
        return MaterialPageRoute(
          builder: (_) =>
              PackagesView(packages: settings.arguments as List<PackageModel>),
        );

      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsView());

      case Routes.notification:
        return MaterialPageRoute(builder: (_) => const NotificationView());

      case Routes.addVehicle:
        return MaterialPageRoute(builder: (_) => const AddCarView());

      // case Routes.language:
      //   return MaterialPageRoute(builder: (_) => const LanguageView());

      //   case Routes.privacyPolicy:
      //     return MaterialPageRoute(builder: (_) => const PrivacyPolicyView());

      //     case Routes.termsAndConditions:
      //       return MaterialPageRoute(builder: (_) => const TermsAndConditionsView());

      //       case Routes.aboutUs:
      //         return MaterialPageRoute(builder: (_) => const AboutUsView());

      //         case Routes.support:
      //           return MaterialPageRoute(builder: (_) => const SupportView());

      default:
        return MaterialPageRoute(builder: (_) => const Placeholder());
    }
  }
}
