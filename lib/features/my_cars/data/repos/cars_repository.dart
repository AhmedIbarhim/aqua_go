import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/my_car_model.dart';
import '../models/vehicle_brand_model.dart';
import '../models/vehicle_model_model.dart';
import '../data_sources/cars_remote_data_source.dart';

class CarsRepository {
  final CarsRemoteDataSource _carsService;
  final List<MyCarModel> _cars = [];
  final StreamController<List<MyCarModel>> _controller =
      StreamController<List<MyCarModel>>.broadcast();

  CarsRepository(this._carsService);

  Stream<List<MyCarModel>> get carsStream => _controller.stream;

  List<MyCarModel> get cars => List.unmodifiable(_cars);

  void _update() {
    _controller.add(List.unmodifiable(_cars));
  }

  Future<Either<Failure, List<VehicleBrandModel>>> getBrands() async {
    final result = await _carsService.getVehicleMakes();
    return result.fold((failure) => Left(failure), (response) {
      if (response.statusCode == 200 && response.data != null) {
        try {
          final List<dynamic> data = response.data as List<dynamic>;
          final brands = data
              .map(
                (json) =>
                    VehicleBrandModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          return Right(brands);
        } catch (e) {
          return Left(ServerFailure('Parsing error: $e'));
        }
      }
      return const Left(ServerFailure('Failed to load vehicle brands'));
    });
  }

  Future<Either<Failure, List<VehicleModelModel>>> getModels(
    String makeId,
  ) async {
    final result = await _carsService.getVehicleModels(makeId);
    return result.fold((failure) => Left(failure), (response) {
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        final models = data
            .map(
              (json) =>
                  VehicleModelModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        return Right(models);
      }
      return const Left(ServerFailure('Failed to load models for brand'));
    });
  }

  Future<Either<Failure, List<MyCarModel>>> fetchCars() async {
    // 1. Ensure makes catalog is loaded first
    final brandsResult = await getBrands();
    if (brandsResult.isLeft()) {
      return Left(
        brandsResult.fold(
          (f) => f,
          (_) => const ServerFailure('Unknown error'),
        ),
      );
    }
    final brandsList = brandsResult.getOrElse(() => []);

    // 2. Fetch customer vehicles
    final result = await _carsService.getVehicles();
    return result.fold((failure) => Left(failure), (response) async {
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data as List<dynamic>;
        final List<MyCarModel> parsedCars = [];

        for (final item in list) {
          final Map<String, dynamic> carJson = item as Map<String, dynamic>;
          final makeId = carJson['makeId'] as String;
          final modelId = carJson['modelId'] as String;

          // Fetch/resolve models for this make (uses cache if already retrieved)
          final modelsResult = await getModels(makeId);
          List<VehicleModelModel> modelsList = [];
          if (modelsResult.isRight()) {
            modelsList = modelsResult.getOrElse(() => []);
          }

          final makeModel = brandsList.firstWhere((m) => m.id == makeId);

          final modelModel = modelsList.firstWhere((m) => m.id == modelId);

          parsedCars.add(
            MyCarModel.fromJson(
              carJson,
              make: makeModel,
              modelRelation: modelModel,
            ),
          );
        }

        _cars.clear();
        _cars.addAll(parsedCars);
        _update();
        return Right(_cars);
      }
      return const Left(ServerFailure('Failed to parse vehicles response'));
    });
  }

  Future<Either<Failure, MyCarModel>> addCar(MyCarModel car) async {
    final Map<String, dynamic> data = car.toMap();

    final result = await _carsService.addVehicle(data);
    return result.fold((failure) => Left(failure), (response) async {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final carJson = response.data as Map<String, dynamic>;

        // Resolve make and model details for the newly created car
        final makesResult = await getBrands();
        final modelsResult = await getModels(car.makeId);

        final makeModel = makesResult.fold(
          (_) => null,
          (list) => list.firstWhere((m) => m.id == car.makeId),
        );
        final modelModel = modelsResult.fold(
          (_) => null,
          (list) => list.firstWhere((m) => m.id == car.modelId),
        );

        final newCar = MyCarModel.fromJson(
          carJson,
          make: makeModel,
          modelRelation: modelModel,
        );

        _cars.add(newCar);
        _update();
        return Right(newCar);
      }
      return const Left(ServerFailure('Failed to save vehicle details'));
    });
  }

  Future<Either<Failure, MyCarModel>> updateCar(MyCarModel car) async {
    final Map<String, dynamic> data = car.toMap();

    final result = await _carsService.updateVehicle(car.id, data);
    return result.fold((failure) => Left(failure), (response) async {
      if (response.statusCode == 200 || response.statusCode == 204) {
        final Map<String, dynamic> carJson =
            (response.data != null && response.data is Map)
            ? response.data as Map<String, dynamic>
            : car.toJson();

        final makesResult = await getBrands();
        final modelsResult = await getModels(car.makeId);

        final makeModel = makesResult.fold(
          (_) => null,
          (list) => list.firstWhere((m) => m.id == car.makeId),
        );
        final modelModel = modelsResult.fold(
          (_) => null,
          (list) => list.firstWhere((m) => m.id == car.modelId),
        );

        final updatedCar = MyCarModel.fromJson(
          carJson,
          make: makeModel,
          modelRelation: modelModel,
        );

        final index = _cars.indexWhere((element) => element.id == car.id);
        if (index != -1) {
          _cars[index] = updatedCar;
          _update();
        }
        return Right(updatedCar);
      }
      return const Left(ServerFailure('Failed to update vehicle details'));
    });
  }

  Future<Either<Failure, void>> deleteCar(String id) async {
    final result = await _carsService.deleteVehicle(id);
    return result.fold((failure) => Left(failure), (response) {
      if (response.statusCode == 200 || response.statusCode == 204) {
        _cars.removeWhere((element) => element.id == id);
        _update();
        return const Right(null);
      }
      return const Left(ServerFailure('Failed to remove vehicle'));
    });
  }

  void dispose() {
    _controller.close();
  }
}
