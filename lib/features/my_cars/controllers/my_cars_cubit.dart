import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/my_car_model.dart';
import '../data/models/vehicle_brand_model.dart';
import '../data/models/vehicle_model_model.dart';
import '../data/repos/cars_repository.dart';

part 'my_cars_state.dart';

class MyCarsCubit extends Cubit<MyCarsState> {
  final CarsRepository _carsRepository;

  MyCarsCubit({required CarsRepository carsRepository})
    : _carsRepository = carsRepository,
      super(MyCarsInitial());

  Future<void> getCars() async {
    emit(MyCarsLoading());
    final result = await _carsRepository.fetchCars();
    result.fold(
      (failure) => emit(MyCarsError(failure.message)),
      (carsList) => emit(MyCarsLoaded(List.from(carsList))),
    );
  }

  Future<void> addCar(MyCarModel car) async {
    emit(MyCarsActionLoading());
    final result = await _carsRepository.addCar(car);
    result.fold((failure) => emit(MyCarsActionError(failure.message)), (
      _,
    ) async {
      await getCars();
      emit(MyCarsActionSuccess());
    });
  }

  Future<void> updateCar(MyCarModel car) async {
    emit(MyCarsActionLoading());
    final result = await _carsRepository.updateCar(car);
    result.fold((failure) => emit(MyCarsActionError(failure.message)), (
      _,
    ) async {
      await getCars();
      emit(MyCarsActionSuccess());
    });
  }

  Future<void> deleteCar(String id) async {
    emit(MyCarsActionLoading());
    final result = await _carsRepository.deleteCar(id);
    result.fold((failure) => emit(MyCarsActionError(failure.message)), (
      _,
    ) async {
      await getCars();
      emit(MyCarsActionSuccess());
    });
  }

  Future<void> getBrands() async {
    emit(BrandsLoading());
    final result = await _carsRepository.getBrands();
    result.fold(
      (failure) => emit(BrandsError(failure.message)),
      (makesList) => emit(BrandsLoaded(makesList)),
    );
  }

  Future<void> getModels(String makeId) async {
    emit(ModelsLoading());
    final result = await _carsRepository.getModels(makeId);
    result.fold(
      (failure) => emit(ModelsError(failure.message)),
      (modelsList) => emit(ModelsLoaded(modelsList)),
    );
  }
}
