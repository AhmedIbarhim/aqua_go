import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/my_car_model.dart';

part 'my_cars_state.dart';

class MyCarsCubit extends Cubit<MyCarsState> {
  // Singleton pattern
  static final MyCarsCubit _instance = MyCarsCubit._internal();
  factory MyCarsCubit() => _instance;
  MyCarsCubit._internal() : super(MyCarsInitial());

  final List<MyCarModel> _cars = [];

  void getCars() {
    emit(MyCarsLoaded(List.from(_cars)));
  }

  void addCar(MyCarModel car) {
    _cars.add(car);
    emit(MyCarsLoaded(List.from(_cars)));
  }

  void deleteCar(String id) {
    _cars.removeWhere((element) => element.id == id);
    emit(MyCarsLoaded(List.from(_cars)));
  }

  void updateCar(MyCarModel updatedCar) {
    final index = _cars.indexWhere((element) => element.id == updatedCar.id);
    if (index != -1) {
      _cars[index] = updatedCar;
      emit(MyCarsLoaded(List.from(_cars)));
    }
  }
}
