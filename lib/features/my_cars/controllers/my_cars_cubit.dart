import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/my_car_model.dart';
import '../data/repos/cars_repository.dart';

part 'my_cars_state.dart';

class MyCarsCubit extends Cubit<MyCarsState> {
  final CarsRepository _carsRepository;
  StreamSubscription? _subscription;

  MyCarsCubit({required CarsRepository carsRepository})
    : _carsRepository = carsRepository,
      super(MyCarsInitial()) {
    _subscription = _carsRepository.carsStream.listen((cars) {
      if (!isClosed) {
        emit(MyCarsLoaded(List.from(cars)));
      }
    });
  }

  void getCars() {
    emit(MyCarsLoaded(List.from(_carsRepository.cars)));
  }

  void addCar(MyCarModel car) {
    _carsRepository.addCar(car);
  }

  void deleteCar(String id) {
    _carsRepository.deleteCar(id);
  }

  void updateCar(MyCarModel updatedCar) {
    _carsRepository.updateCar(updatedCar);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
