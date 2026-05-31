import 'package:aqua_go/features/address/controllers/addresses_controller/addresses_cubit.dart';
import 'package:aqua_go/features/address/data/repos/addresses_repository.dart';
import 'package:aqua_go/features/address/data/data_sources/addresses_remote_data_source.dart';
import 'package:aqua_go/features/address/controllers/maps_controller/maps_cubit.dart';
import 'package:aqua_go/features/address/data/repos/maps_repository.dart';
import 'package:aqua_go/features/auth/controllers/auth_cubit/auth_cubit.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repository.dart';
import 'package:aqua_go/features/auth/data/services/auth_service.dart';
import 'package:aqua_go/features/my_cars/data/data_sources/cars_remote_data_source.dart';
import 'package:aqua_go/features/my_cars/data/repos/cars_repository.dart';
import 'package:aqua_go/features/my_cars/controllers/my_cars_cubit.dart';
import 'package:aqua_go/features/booking_and_subscriptions/booking/data/repos/booking_repo.dart';
import 'package:aqua_go/features/booking_and_subscriptions/booking/controllers/booking_cubit.dart';
import 'package:aqua_go/features/home/data/data_source/services_remote_data_source.dart';
import 'package:aqua_go/features/home/data/data_source/banners_remote_data_source.dart';
import 'package:aqua_go/features/home/data/data_source/packages_remote_data_source.dart';
import 'package:aqua_go/features/booking_and_subscriptions/subscriptions/data/data_sources/subscriptions_remote_data_source.dart';
import 'package:aqua_go/features/home/data/repos/services_repository.dart';
import 'package:aqua_go/features/home/data/repos/banners_repository.dart';
import 'package:aqua_go/features/home/data/repos/packages_repository.dart';
import 'package:aqua_go/features/booking_and_subscriptions/subscriptions/data/repos/subscriptions_repository.dart';
import 'package:aqua_go/features/home/controllers/services_controller/services_cubit.dart';
import 'package:aqua_go/features/home/controllers/banners_controller/banners_cubit.dart';
import 'package:aqua_go/features/home/controllers/packages_controller/packages_cubit.dart';
import 'package:aqua_go/features/booking_and_subscriptions/subscriptions/controllers/subscriptions_controller/subscriptions_cubit.dart';
import 'package:aqua_go/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:aqua_go/features/profile/data/repos/profile_repository.dart';
import 'package:aqua_go/features/profile/controllers/notification_preferences_cubit/notification_preferences_cubit.dart';
import 'package:aqua_go/features/notifications/data/data_sources/notifications_remote_data_source.dart';
import 'package:aqua_go/features/notifications/data/repos/notifications_repository.dart';
import 'package:aqua_go/features/notifications/controllers/notifications_cubit/notifications_cubit.dart';
import 'package:aqua_go/features/my_bookings/data/data_sources/my_bookings_remote_data_source.dart';
import 'package:aqua_go/features/my_bookings/data/repos/my_bookings_repository.dart';
import 'package:aqua_go/features/my_bookings/controllers/my_bookings_cubit.dart';
import 'package:aqua_go/features/my_bookings/controllers/my_booking_details_cubit.dart';
import 'package:get_it/get_it.dart';

import '../../../features/address/data/services/location_service.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import '../networking/api_client.dart';
import '../networking/dio_factory.dart';

final GetIt locator = GetIt.instance;

Future<void> initServiceLocator() async {
  locator.registerLazySingleton<APIClient>(
    () => APIClient(DioFactory.create(baseUrl: Endpoints.baseUrl)),
  );

  // Services

  locator.registerLazySingleton<LocationService>(
    () => LocationService(apiClient: locator()),
  );

  locator.registerLazySingleton<AuthService>(() => AuthService(locator()));
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
  locator.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(locator()),
  );
  locator.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepository(locator()),
  );
  locator.registerLazySingleton<MyBookingsRepository>(
    () => MyBookingsRepository(locator()),
  );

  locator.registerLazySingleton<BookingRepo>(
    () => BookingRepo(apiClient: locator()),
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

  locator.registerFactory<SubscriptionsCubit>(
    () => SubscriptionsCubit(subscriptionsRepository: locator()),
  );

  locator.registerFactory<AuthCubit>(() => AuthCubit(locator()));

  locator.registerFactory<BookingCubit>(
    () => BookingCubit(bookingRepo: locator()),
  );

  locator.registerFactory<NotificationPreferencesCubit>(
    () => NotificationPreferencesCubit(locator()),
  );

  locator.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(locator()),
  );

  locator.registerFactory<MyBookingsCubit>(
    () => MyBookingsCubit(locator()),
  );
  locator.registerFactory<MyBookingDetailsCubit>(
    () => MyBookingDetailsCubit(locator()),
  );
}
