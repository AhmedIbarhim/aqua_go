import 'package:aqua_go/features/address/presentation/controllers/addresses_controller/addresses_cubit.dart';
import 'package:aqua_go/features/address/data/repos/addresses_repository.dart';
import 'package:aqua_go/features/address/data/data_sources/addresses_remote_data_source.dart';
import 'package:aqua_go/features/address/presentation/controllers/maps_controller/maps_cubit.dart';
import 'package:aqua_go/features/address/data/repos/maps_repository.dart';
import 'package:aqua_go/features/auth/presentation/controllers/auth_cubit/auth_cubit.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repository.dart';
import 'package:aqua_go/features/auth/data/services/auth_service.dart';
import 'package:aqua_go/features/auth/data/repos/device_repository.dart';
import 'package:aqua_go/features/auth/data/services/device_service.dart';
import 'package:aqua_go/features/my_cars/data/data_sources/cars_remote_data_source.dart';
import 'package:aqua_go/features/my_cars/data/repos/cars_repository.dart';
import 'package:aqua_go/features/my_cars/presentation/controllers/my_cars_cubit.dart';
import 'package:aqua_go/features/booking/data/repos/booking_repository.dart';
import 'package:aqua_go/features/booking/data/data_sources/bookings_remote_data_source.dart';
import 'package:aqua_go/features/home/data/data_source/services_remote_data_source.dart';
import 'package:aqua_go/features/home/data/data_source/banners_remote_data_source.dart';
import 'package:aqua_go/features/home/data/data_source/packages_remote_data_source.dart';
import 'package:aqua_go/features/subscriptions/data/data_sources/subscriptions_remote_data_source.dart';
import 'package:aqua_go/features/home/data/repos/services_repository.dart';
import 'package:aqua_go/features/home/data/repos/banners_repository.dart';
import 'package:aqua_go/features/home/data/repos/packages_repository.dart';
import 'package:aqua_go/features/subscriptions/data/repos/subscriptions_repository.dart';
import 'package:aqua_go/features/home/presentation/controllers/services_controller/services_cubit.dart';
import 'package:aqua_go/features/home/presentation/controllers/banners_controller/banners_cubit.dart';
import 'package:aqua_go/features/home/presentation/controllers/packages_controller/packages_cubit.dart';
import 'package:aqua_go/features/subscriptions/presentation/controllers/subscriptions_controller/subscriptions_cubit.dart';
import 'package:aqua_go/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:aqua_go/features/profile/data/repos/profile_repository.dart';
import 'package:aqua_go/features/profile/presentation/controllers/notification_preferences_cubit/notification_preferences_cubit.dart';
import 'package:aqua_go/features/profile/presentation/controllers/support_cubit/support_cubit.dart';
import 'package:aqua_go/features/notifications/data/data_sources/notifications_remote_data_source.dart';
import 'package:aqua_go/features/notifications/data/repos/notifications_repository.dart';
import 'package:aqua_go/features/notifications/presentation/controllers/notifications_cubit/notifications_cubit.dart';
import 'package:aqua_go/features/my_bookings/data/data_sources/my_bookings_remote_data_source.dart';
import 'package:aqua_go/features/my_bookings/data/repos/my_bookings_repository.dart';
import 'package:aqua_go/features/my_bookings/presentation/controllers/my_bookings_cubit.dart';
import 'package:aqua_go/features/my_bookings/presentation/controllers/my_booking_details_cubit.dart';
import 'package:aqua_go/features/gifts/data/data_sources/gifts_remote_data_source.dart';
import 'package:aqua_go/features/gifts/data/repos/gifts_repository.dart';
import 'package:aqua_go/features/gifts/presentation/controllers/gifts_cubit.dart';
import 'package:aqua_go/features/gifts/presentation/controllers/send_gift_cubit.dart';
import 'package:aqua_go/features/complaints/data/data_sources/complaints_remote_data_source.dart';
import 'package:aqua_go/features/complaints/data/repos/complaints_repository.dart';
import 'package:aqua_go/features/complaints/presentation/controllers/complaints_cubit/complaints_cubit.dart';
import 'package:aqua_go/features/complaints/presentation/controllers/complaint_details_cubit/complaint_details_cubit.dart';
import 'package:aqua_go/features/rating/data/data_sources/rating_remote_data_source.dart';
import 'package:aqua_go/features/rating/data/data_sources/tips_remote_data_source.dart';
import 'package:aqua_go/features/rating/data/repos/rating_repository.dart';
import 'package:aqua_go/features/rating/data/repos/tips_repository.dart';
import 'package:aqua_go/features/rating/presentation/controllers/rating_cubit/rating_cubit.dart';
import 'package:aqua_go/features/rating/presentation/controllers/pending_ratings_cubit/pending_ratings_cubit.dart';
import 'package:aqua_go/features/rating/presentation/controllers/paying_tips_cubit/paying_tips_cubit.dart';
import 'package:aqua_go/features/support/data/data_sources/faqs_remote_data_source.dart';
import 'package:aqua_go/features/support/data/repos/faqs_repository.dart';
import 'package:aqua_go/features/support/presentation/controllers/faqs_cubit.dart';
import 'package:aqua_go/features/wallet/data/data_sources/wallet_remote_data_source.dart';
import 'package:aqua_go/features/wallet/data/repos/wallet_repository.dart';
import 'package:aqua_go/features/wallet/presentation/controllers/wallet_cubit.dart';
import 'package:aqua_go/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:aqua_go/features/chat/data/repos/chat_repository.dart';
import 'package:aqua_go/features/chat/presentation/controllers/chat_threads_cubit/chat_threads_cubit.dart';
import 'package:get_it/get_it.dart';

import '../../../features/address/data/services/location_service.dart';
import '../networking/api_client.dart';
import '../networking/dio_factory.dart';
import 'package:aqua_go/main/app_configs.dart';

final GetIt locator = GetIt.instance;

Future<void> initServiceLocator(AppConfigs configs) async {
  locator.registerSingleton<AppConfigs>(configs);
  locator.registerLazySingleton<APIClient>(
    () => APIClient(DioFactory.create(baseUrl: configs.baseUrl)),
  );

  // Services

  locator.registerLazySingleton<LocationService>(
    () => LocationService(apiClient: locator()),
  );

  locator.registerLazySingleton<AuthService>(() => AuthService(locator()));
  locator.registerLazySingleton<DeviceService>(() => DeviceService(locator()));
  locator.registerLazySingleton<CarsRemoteDataSource>(
    () => CarsRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<AddressesRemoteDataSource>(
    () => AddressesRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<ServicesRemoteDataSource>(
    () => ServicesRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<BannersRemoteDataSource>(
    () => BannersRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<PackagesRemoteDataSource>(
    () => PackagesRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<SubscriptionsRemoteDataSource>(
    () => SubscriptionsRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<MyBookingsRemoteDataSource>(
    () => MyBookingsRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<GiftsRemoteDataSource>(
    () => GiftsRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<BookingsRemoteDataSource>(
    () => BookingsRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<ComplaintsRemoteDataSource>(
    () => ComplaintsRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<RatingRemoteDataSource>(
    () => RatingRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<TipsRemoteDataSource>(
    () => TipsRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<FaqsRemoteDataSource>(
    () => FaqsRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSource(locator()),
  );
  locator.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(locator()),
  );

  // Repositories

  locator.registerLazySingleton<MapsRepository>(
    () => MapsRepository(locationService: locator()),
  );

  locator.registerLazySingleton<AddressesRepository>(
    () => AddressesRepository(locator()),
  );

  locator.registerLazySingleton<CarsRepository>(
    () => CarsRepository(locator()),
  );

  locator.registerLazySingleton<ServicesRepository>(
    () => ServicesRepository(locator()),
  );

  locator.registerLazySingleton<BannersRepository>(
    () => BannersRepository(locator()),
  );

  locator.registerLazySingleton<PackagesRepository>(
    () => PackagesRepository(locator()),
  );

  locator.registerLazySingleton<SubscriptionsRepository>(
    () => SubscriptionsRepository(locator()),
  );

  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(locator()),
  );
  locator.registerLazySingleton<DeviceRepository>(
    () => DeviceRepository(locator()),
  );
  locator.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(locator()),
  );
  locator.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepository(locator()),
  );
  locator.registerLazySingleton<MyBookingsRepository>(
    () => MyBookingsRepository(locator()),
  );
  locator.registerLazySingleton<GiftsRepository>(
    () => GiftsRepository(locator()),
  );

  locator.registerLazySingleton<BookingRepository>(
    () => BookingRepository(bookingsRemoteDataSource: locator()),
  );
  locator.registerLazySingleton<ComplaintsRepository>(
    () => ComplaintsRepository(locator()),
  );
  locator.registerLazySingleton<RatingRepository>(
    () => RatingRepository(locator()),
  );
  locator.registerLazySingleton<TipsRepository>(
    () => TipsRepository(locator()),
  );
  locator.registerLazySingleton<FaqsRepository>(
    () => FaqsRepository(locator()),
  );
  locator.registerLazySingleton<WalletRepository>(
    () => WalletRepository(locator()),
  );
  locator.registerLazySingleton<ChatRepository>(
    () => ChatRepository(locator()),
  );

  // Cubits

  locator.registerFactory<MapsCubit>(
    () => MapsCubit(mapsRepository: locator()),
  );

  locator.registerFactory<MyCarsCubit>(
    () => MyCarsCubit(carsRepository: locator()),
  );

  locator.registerFactory<AddressesCubit>(
    () => AddressesCubit(repository: locator()),
  );

  locator.registerFactory<ServicesCubit>(
    () => ServicesCubit(servicesRepository: locator()),
  );

  locator.registerFactory<BannersCubit>(
    () => BannersCubit(bannersRepository: locator()),
  );

  locator.registerFactory<PackagesCubit>(
    () => PackagesCubit(packagesRepository: locator()),
  );

  // Lazy singleton so every surface that displays the user's subscriptions
  // (home current-package section, packages screen, my-subscribed-packages
  // screen) shares ONE instance. A successful subscribe refetches that single
  // instance, so the new subscription appears everywhere without a manual
  // pull-to-refresh.
  locator.registerLazySingleton<SubscriptionsCubit>(
    () => SubscriptionsCubit(subscriptionsRepository: locator()),
  );

  locator.registerFactory<AuthCubit>(() => AuthCubit(locator()));

  locator.registerFactory<NotificationPreferencesCubit>(
    () => NotificationPreferencesCubit(locator()),
  );

  locator.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(locator()),
  );

  locator.registerFactory<MyBookingsCubit>(() => MyBookingsCubit(locator()));
  locator.registerFactory<GiftsCubit>(() => GiftsCubit(locator()));
  locator.registerFactory<SendGiftCubit>(
    () => SendGiftCubit(
      giftsRepository: locator(),
      servicesRepository: locator(),
    ),
  );
  locator.registerFactory<MyBookingDetailsCubit>(
    () => MyBookingDetailsCubit(locator()),
  );
  locator.registerFactory<ComplaintsCubit>(() => ComplaintsCubit(locator()));
  locator.registerFactory<ComplaintDetailsCubit>(
    () => ComplaintDetailsCubit(locator(), locator()),
  );
  locator.registerFactory<RatingCubit>(() => RatingCubit(locator()));
  locator.registerFactory<PendingRatingsCubit>(
    () => PendingRatingsCubit(locator()),
  );
  locator.registerFactory<PayingTipsCubit>(() => PayingTipsCubit(locator()));
  locator.registerFactory<FaqsCubit>(() => FaqsCubit(locator()));
  locator.registerFactory<SupportCubit>(() => SupportCubit(locator()));
  locator.registerFactory<WalletCubit>(() => WalletCubit(locator()));
  // ChatThreadsCubit drives the support inbox. ChatThreadCubit (a single open
  // thread) is NOT registered here — it needs threadId + currentUserId +
  // initialThread ctor args, so the router constructs it with locator<ChatRepository>().
  locator.registerFactory<ChatThreadsCubit>(
    () => ChatThreadsCubit(locator()),
  );
}
