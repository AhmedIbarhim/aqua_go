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
import 'package:aqua_go/features/booking/data/repos/booking_repo.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_cubit.dart';
import 'package:aqua_go/features/home/data/data_source/services_remote_data_source.dart';
import 'package:aqua_go/features/home/data/repos/services_repository.dart';
import 'package:aqua_go/features/home/controllers/services_controller/services_cubit.dart';
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

  // Repositories

  locator.registerLazySingleton<MapsRepository>(
    () => MapsRepository(locationService: locator()),
  );

  locator.registerLazySingleton<AddressesRepository>(
    () => AddressesRepository(locator()),
    dispose: (repo) => repo.dispose(),
  );

  locator.registerLazySingleton<CarsRepository>(
    () => CarsRepository(locator()),
    dispose: (repo) => repo.dispose(),
  );

  locator.registerLazySingleton<ServicesRepository>(
    () => ServicesRepository(locator()),
  );

  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(locator()),
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

  locator.registerFactory<AuthCubit>(() => AuthCubit(locator()));

  locator.registerFactory<BookingCubit>(
    () => BookingCubit(bookingRepo: locator()),
  );
}
