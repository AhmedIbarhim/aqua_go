import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/booking/controllers/booking_cubit.dart';
import '../../features/booking/domain/configs/booking_flow_config.dart';
import '../../features/booking/domain/strategies/booking_submit_strategy.dart';
import '../../features/booking/domain/strategies/service_booking_submit.dart';
import '../../../../core/config/di/service_locator.dart';
import '../../features/subscriptions/data/repos/subscriptions_repository.dart';
import '../../features/address/presentation/views/my_addresses_view.dart';
import '../../features/address/presentation/views/new_address_map_view.dart';
import '../../features/auth/presentation/views/add_email_view.dart';
import '../../features/auth/presentation/views/email_otp_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/phone_otp_view.dart';
import '../../features/booking/presentation/views/booking_details_view.dart';
import '../../features/booking/presentation/views/booking_location_view.dart';
import '../../features/booking/presentation/views/booking_summary_view.dart';
import '../../features/home/controllers/packages_controller/packages_cubit.dart';
import '../../features/home/presentation/views/offers_view.dart';
import '../../features/home/presentation/views/packages_view.dart';
import '../../features/layout/presentation/views/main_layout.dart';
import '../../features/complaints/presentation/views/complaint_view.dart';
import '../../features/complaints/presentation/views/complaints_record_view.dart';
import '../../features/complaints/presentation/views/complaint_details_view.dart';
import '../../features/complaints/controllers/complaints_cubit/complaints_cubit.dart';
import '../../features/complaints/controllers/complaint_details_cubit/complaint_details_cubit.dart';
import '../../features/my_bookings/presentation/views/gallery_view.dart';
import '../../features/my_bookings/presentation/views/my_booking_deatails_view.dart';
import '../../features/my_cars/data/models/my_car_model.dart';
import '../../features/home/data/models/service_model.dart';
import '../../features/address/data/models/address_model.dart';
import '../../features/booking/data/repos/booking_repository.dart';
import '../../features/profile/presentation/views/language_select_view.dart';
import '../../features/profile/presentation/views/profile_data_view.dart';
import '../../features/startup/views/onboarding_view.dart';
import '../../features/startup/views/splash_view.dart';
import '../../features/notifications/presentation/views/notification_view.dart';
import '../../features/profile/presentation/views/settings_view.dart';
import '../../features/my_cars/controllers/my_cars_cubit.dart';
import '../../features/my_cars/presentation/views/add_car_view.dart';
import '../../features/profile/presentation/views/privacy_policy_view.dart';
import '../../features/profile/presentation/views/about_us_view.dart';
import '../../features/profile/presentation/views/terms_view.dart';
import '../../features/profile/presentation/views/support_view.dart';

import '../../features/my_bookings/controllers/my_booking_details_cubit.dart';

import 'routes.dart';

abstract class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
          builder: (_) =>
              EmailOtpView(email: args.email, otpSessionId: args.otpSessionId),
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
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => locator<PackagesCubit>()..getPackages(),
            child: const PackagesView(),
          ),
        );

      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsView());

      case Routes.languageSelect:
        return MaterialPageRoute(builder: (_) => const LanguageSelectView());

      case Routes.notification:
        return MaterialPageRoute(builder: (_) => const NotificationView());

      case Routes.addVehicle:
        final car = settings.arguments as MyCarModel?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => locator<MyCarsCubit>(),
            child: AddCarView(car: car),
          ),
        );

      case Routes.bookingDetails:
        final args = settings.arguments as BookingFlowArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: args.bookingCubit,
            child: const BookingDetailsView(),
          ),
        );

      case Routes.bookingLocation:
        final args = settings.arguments as BookingFlowStartArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                BookingCubit(
                  bookingRepo: locator<BookingRepository>(),
                  subscriptionsRepo: locator<SubscriptionsRepository>(),
                  flowConfig: args.flowConfig,
                  submitStrategy: args.submitStrategy,
                )..initBooking(
                  args.service,
                  existingCar: args.existingCar,
                  existingAddress: args.existingAddress,
                  subscriptionId: args.subscriptionId,
                  washId: args.washId,
                ),
            child: const BookingLocationView(),
          ),
        );

      case Routes.bookingSummary:
        final args = settings.arguments as BookingFlowArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: args.bookingCubit,
            child: const BookingSummaryView(),
          ),
        );

      case Routes.newAddressMap:
        final args = settings.arguments as NewAddressMapArgs;
        return MaterialPageRoute(
          builder: (_) => NewAddressMapView(
            forAddingAddess: args.forAddingAddress,
            address: args.address,
          ),
        );
      case Routes.complain:
        final args = settings.arguments as ComplaintArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => locator<ComplaintsCubit>(),
            child: ComplaintView(booking: args.booking),
          ),
        );

      case Routes.complainsRecord:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => locator<ComplaintsCubit>()..fetchComplaints(),
            child: const ComplaintsRecordView(),
          ),
        );

      case Routes.myBookingDetails:
        final args = settings.arguments as MyBookingDetailsArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                locator<MyBookingDetailsCubit>()
                  ..fetchBookingDetails(args.booking.id ?? ''),
            child: MyBookingDetailsView(
              booking: args.booking,
              isFromBookingFlow: args.isFromBookingFlow,
            ),
          ),
        );

      case Routes.gallery:
        final args = settings.arguments as GalleryArgs;
        return MaterialPageRoute(
          builder: (_) => GalleryView(
            images: args.images,
            initialIndex: args.initialIndex,
            labels: args.labels,
          ),
        );

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

      case Routes.complaintDetails:
        final args = settings.arguments as ComplaintDetailsArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                locator<ComplaintDetailsCubit>()
                  ..fetchComplaintDetails(args.complaintId),
            child: ComplaintDetailsView(
              complaintId: args.complaintId,
              initialComplaint: args.initialComplaint,
            ),
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const Placeholder());
    }
  }
}

/// Args for passing an already-created BookingCubit between views in the flow.
class BookingFlowArgs {
  final BookingCubit bookingCubit;
  BookingFlowArgs({required this.bookingCubit});
}

/// Args for starting a new booking flow (creates the cubit in the router).
class BookingFlowStartArgs {
  final ServiceModel? service;
  final MyCarModel? existingCar;
  final AddressModel? existingAddress;
  final BookingFlowConfig flowConfig;
  final BookingSubmitStrategy submitStrategy;
  final String? subscriptionId;
  final String? washId;

  BookingFlowStartArgs({
    this.service,
    this.existingCar,
    this.existingAddress,
    this.flowConfig = BookingFlowConfig.normal,
    BookingSubmitStrategy? submitStrategy,
    this.subscriptionId,
    this.washId,
  }) : submitStrategy = submitStrategy ?? ServiceBookingSubmit();
}
