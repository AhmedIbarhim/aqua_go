import 'package:flutter/material.dart';
import '../../features/adress/presentation/views/my_addresses_view.dart';
import '../../features/adress/presentation/views/new_address_map_view.dart';
import '../../features/auth/presentation/views/add_email_view.dart';
import '../../features/auth/presentation/views/email_otp_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/phone_otp_view.dart';
import '../../features/booking/presentation/views/booking_details_view.dart';
import '../../features/booking/presentation/views/booking_location_view.dart';
import '../../features/booking/presentation/views/booking_summary_view.dart';
import '../../features/home/presentation/views/offers_view.dart';
import '../../features/home/presentation/views/packages_view.dart';
import '../../features/layout/presentation/views/main_layout.dart';
import '../../features/my_bookings/presentation/views/complain_view.dart';
import '../../features/my_bookings/presentation/views/gallery_view.dart';
import '../../features/my_bookings/presentation/views/my_booking_deatails_view.dart';
import '../../features/my_cars/data/models/my_car_model.dart';
import '../../features/profile/presentation/views/language_select_view.dart';
import '../../features/profile/presentation/views/profile_data_view.dart';
import '../../features/startup/views/onboarding_view.dart';
import '../../features/startup/views/splash_view.dart';
import '../../features/notifications/presentation/views/notification_view.dart';
import '../../features/profile/presentation/views/settings_view.dart';
import '../../features/my_cars/presentation/views/add_car_view.dart';
import '../../features/profile/presentation/views/privacy_policy_view.dart';
import '../../features/profile/presentation/views/about_us_view.dart';
import '../../features/profile/presentation/views/terms_view.dart';
import '../../features/profile/presentation/views/support_view.dart';

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

      case Routes.phoneOtp:
        final args = settings.arguments as PhoneOtpArgs;
        return MaterialPageRoute(
          builder: (_) => PhoneOtpView(phoneNumber: args.phoneNumber),
        );

      case Routes.emailOtp:
        final args = settings.arguments as EmailOtpArgs;
        return MaterialPageRoute(
          builder: (_) => EmailOtpView(email: args.email),
        );

      case Routes.addEmail:
        return MaterialPageRoute(builder: (_) => const AddEmailView());

      case Routes.layout:
        return MaterialPageRoute(builder: (_) => const MainLayout());

      case Routes.offers:
        final args = settings.arguments as OffersArgs;
        return MaterialPageRoute(
          builder: (_) => OffersView(offers: args.offers),
        );

      case Routes.packages:
        final args = settings.arguments as PackagesArgs;
        return MaterialPageRoute(
          builder: (_) => PackagesView(packages: args.packages),
        );

      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsView());

      case Routes.languageSelect:
        return MaterialPageRoute(builder: (_) => const LanguageSelectView());

      case Routes.notification:
        return MaterialPageRoute(builder: (_) => const NotificationView());

      case Routes.addVehicle:
        final car = settings.arguments as MyCarModel?;
        return MaterialPageRoute(builder: (_) => AddCarView(car: car));

      case Routes.bookingDetails:
        return MaterialPageRoute(builder: (_) => const BookingDetailsView());

      case Routes.bookingLocation:
        return MaterialPageRoute(builder: (_) => const BookingLocationView());

      case Routes.bookingSummary:
        return MaterialPageRoute(builder: (_) => const BookingSummaryView());

      case Routes.newAddressMap:
        final args = settings.arguments as NewAddressMapArgs;
        return MaterialPageRoute(
          builder: (_) => NewAddressMapView(
            forAddingAddess: args.forAddingAddress,
            address: args.address,
          ),
        );
      case Routes.complain:
        final args = settings.arguments as ComplainArgs;
        return MaterialPageRoute(
          builder: (_) => ComplainView(booking: args.booking),
        );

      case Routes.myBookingDetails:
        final args = settings.arguments as MyBookingDetailsArgs;
        return MaterialPageRoute(
          builder: (_) => MyBookingDetailsView(booking: args.booking),
        );

      case Routes.gallery:
        final args = settings.arguments as GalleryArgs;
        return MaterialPageRoute(
          builder: (_) =>
              GalleryView(images: args.images, initialIndex: args.initialIndex),
        );
      // case Routes.language:
      //   return MaterialPageRoute(builder: (_) => const LanguageView());

      case Routes.privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyView());

      case Routes.termsAndConditions:
        return MaterialPageRoute(builder: (_) => const TermsView());

      case Routes.aboutUs:
        return MaterialPageRoute(builder: (_) => const AboutUsView());

      case Routes.support:
        return MaterialPageRoute(builder: (_) => const SupportView());

      case Routes.profileData:
        final isFirstTime = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => ProfileDataView(isFirstTime: isFirstTime),
        );


      case Routes.myAddresses:
        return MaterialPageRoute(builder: (_) => const MyAddressesView());

      default:
        return MaterialPageRoute(builder: (_) => const Placeholder());
    }
  }
}
