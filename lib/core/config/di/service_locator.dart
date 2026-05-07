import 'package:aqua_go/features/adress/controllers/maps_controller/maps_cubit.dart';
import 'package:aqua_go/features/adress/data/repos/maps_repo.dart';
import 'package:get_it/get_it.dart';

import '../../../features/adress/data/services/location_service.dart';
import '../networking/api_client.dart';

final GetIt locator = GetIt.instance;

Future<void> initServiceLocator() async {
  locator.registerLazySingleton<APIClient>(() => APIClient(baseUrl: ""));

  locator.registerLazySingleton<LocationService>(
    () => LocationService(apiClient: locator()),
  );

  locator.registerLazySingleton<MapsRepository>(
    () => MapsRepository(locationService: locator()),
  );

  locator.registerFactory<MapsCubit>(
    () => MapsCubit(mapsRepository: locator()),
  );
}
