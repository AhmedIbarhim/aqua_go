import 'dart:async';
import '../../data/models/my_car_model.dart';

class CarsRepository {
  final List<MyCarModel> _cars = [];
  final StreamController<List<MyCarModel>> _controller =
      StreamController<List<MyCarModel>>.broadcast();

  Stream<List<MyCarModel>> get carsStream => _controller.stream;

  List<MyCarModel> get cars => List.unmodifiable(_cars);

  void _update() {
    _controller.add(List.unmodifiable(_cars));
  }

  void addCar(MyCarModel car) {
    _cars.add(car);
    _update();
  }

  void deleteCar(String id) {
    _cars.removeWhere((element) => element.id == id);
    _update();
  }

  void updateCar(MyCarModel updatedCar) {
    final index = _cars.indexWhere((element) => element.id == updatedCar.id);
    if (index != -1) {
      _cars[index] = updatedCar;
      _update();
    }
  }
}
