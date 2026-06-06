import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../models/my_car_model.dart';
import '../models/vehicle_make_model.dart';
import '../models/vehicle_model_model.dart';
import '../data_sources/cars_remote_data_source.dart';

class CarsRepository {
  final CarsRemoteDataSource _carsService;
  final Map<String, VehicleMakeModel> _makeCache = {};
  final Map<String, VehicleModelModel> _modelCache = {};

  CarsRepository(this._carsService);

  Future<Either<Failure, VehicleMakeModel>> getMakeDetails(String makeId) async {
    if (_makeCache.containsKey(makeId)) {
      return Right(_makeCache[makeId]!);
    }
    final result = await _carsService.getVehicleMakeDetails(makeId);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final make = VehicleMakeModel.fromJson(data as Map<String, dynamic>);
            _makeCache[makeId] = make;
            return Right(make);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load vehicle make details'));
      },
    );
  }

  Future<Either<Failure, VehicleModelModel>> getModelDetails(String modelId) async {
    if (_modelCache.containsKey(modelId)) {
      return Right(_modelCache[modelId]!);
    }
    final result = await _carsService.getVehicleModelDetails(modelId);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final model = VehicleModelModel.fromJson(data as Map<String, dynamic>);
            _modelCache[modelId] = model;
            return Right(model);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load vehicle model details'));
      },
    );
  }

  Future<Either<Failure, List<VehicleMakeModel>>> getBrands() async {
    final result = await _carsService.getVehicleMakes();
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final List<dynamic> list = data as List<dynamic>;
          final brands = list
              .map(
                (json) =>
                    VehicleMakeModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          for (final brand in brands) {
            _makeCache[brand.id] = brand;
          }
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
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        final List<dynamic> list = data as List<dynamic>;
        final models = list
            .map(
              (json) =>
                  VehicleModelModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        for (final model in models) {
          _modelCache[model.id] = model;
        }
        return Right(models);
      }
      return const Left(ServerFailure('Failed to load models for brand'));
    });
  }

  Future<Either<Failure, List<MyCarModel>>> fetchCars() async {
    final result = await _carsService.getVehicles();
    return result.fold((failure) => Left(failure), (data) async {
      if (data != null) {
        final List<dynamic> list = data as List<dynamic>;
        final List<MyCarModel> parsedCars = [];

        for (final item in list) {
          final Map<String, dynamic> carJson = item as Map<String, dynamic>;
          final makeId = carJson['makeId'] as String;
          final modelId = carJson['modelId'] as String;

          final makeResult = await getMakeDetails(makeId);
          final modelResult = await getModelDetails(modelId);

          final makeModel = makeResult.fold((_) => null, (m) => m);
          final modelModel = modelResult.fold((_) => null, (m) => m);

          parsedCars.add(
            MyCarModel.fromJson(
              carJson,
              make: makeModel,
              modelRelation: modelModel,
            ),
          );
        }

        return Right(parsedCars);
      }
      return const Left(ServerFailure('Failed to parse vehicles response'));
    });
  }

  Future<Either<Failure, MyCarModel>> addCar(MyCarModel car) async {
    final Map<String, dynamic> data = car.toMap();

    final result = await _carsService.addVehicle(data);
    return result.fold((failure) => Left(failure), (responseData) async {
      if (responseData != null) {
        final carJson = responseData as Map<String, dynamic>;

        final makeResult = await getMakeDetails(car.makeId);
        final modelResult = await getModelDetails(car.modelId);

        final makeModel = makeResult.fold((_) => null, (m) => m);
        final modelModel = modelResult.fold((_) => null, (m) => m);

        final newCar = MyCarModel.fromJson(
          carJson,
          make: makeModel,
          modelRelation: modelModel,
        );

        return Right(newCar);
      }
      return const Left(ServerFailure('Failed to save vehicle details'));
    });
  }

  Future<Either<Failure, MyCarModel>> updateCar(MyCarModel car) async {
    final Map<String, dynamic> data = car.toMap();

    final result = await _carsService.updateVehicle(car.id, data);
    return result.fold((failure) => Left(failure), (responseData) async {
      final Map<String, dynamic> carJson =
          (responseData != null && responseData is Map)
          ? responseData as Map<String, dynamic>
          : car.toJson();

      final makeResult = await getMakeDetails(car.makeId);
      final modelResult = await getModelDetails(car.modelId);

      final makeModel = makeResult.fold((_) => null, (m) => m);
      final modelModel = modelResult.fold((_) => null, (m) => m);

      final updatedCar = MyCarModel.fromJson(
        carJson,
        make: makeModel,
        modelRelation: modelModel,
      );

      return Right(updatedCar);
    });
  }

  Future<Either<Failure, void>> deleteCar(String id) async {
    final result = await _carsService.deleteVehicle(id);
    return result.fold((failure) => Left(failure), (_) {
      return const Right(null);
    });
  }
}
