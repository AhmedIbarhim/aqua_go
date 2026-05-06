import 'package:aqua_go/features/adress/data/repos/maps_repo.dart';
import 'package:get_it/get_it.dart';

import '../../features/adress/data/services/location_service.dart';

final GetIt locator = GetIt.instance;

Future<void> init() async {
  locator.registerLazySingleton<LocationService>(() => LocationService());

  locator.registerLazySingleton<MapsRepository>(
    () => MapsRepository(locationService: locator()),
  );
}
