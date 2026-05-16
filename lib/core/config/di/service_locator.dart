import 'package:aqua_go/features/adress/controllers/addresses_controller/addresses_cubit.dart';
import 'package:aqua_go/features/adress/data/repos/addresses_repository.dart';
import 'package:aqua_go/features/adress/controllers/maps_controller/maps_cubit.dart';
import 'package:aqua_go/features/adress/data/repos/maps_repository.dart';
import 'package:aqua_go/features/auth/controllers/auth_cubit/auth_cubit.dart';
import 'package:aqua_go/features/auth/data/repos/auth_repo.dart';
import 'package:aqua_go/features/auth/data/services/auth_service.dart';
import 'package:aqua_go/features/my_cars/data/repos/cars_repository.dart';
import 'package:aqua_go/features/my_cars/controllers/my_cars_cubit.dart';
import 'package:get_it/get_it.dart';

import '../../../features/adress/data/services/location_service.dart';
import '../networking/api_client.dart';

final GetIt locator = GetIt.instance;

Future<void> initServiceLocator() async {
  locator.registerLazySingleton<APIClient>(() => APIClient(baseUrl: ""));

  locator.registerLazySingleton<LocationService>(
    () => LocationService(apiClient: locator()),
  );

  locator.registerLazySingleton<AuthService>(() => AuthService(locator()));

  // Repositories

  locator.registerLazySingleton<MapsRepository>(
    () => MapsRepository(locationService: locator()),
  );

  locator.registerLazySingleton<AddressesRepository>(
    () => AddressesRepository(),
  );

  locator.registerLazySingleton<CarsRepository>(() => CarsRepository());

  locator.registerLazySingleton<AuthRepo>(() => AuthRepo(locator()));

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

  locator.registerFactory<AuthCubit>(() => AuthCubit(locator()));
}
