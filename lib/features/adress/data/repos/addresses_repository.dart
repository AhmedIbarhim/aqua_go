import 'dart:async';
import '../../data/models/address_model.dart';

class AddressesRepository {
  final List<AddressModel> _addresses = [];
  final StreamController<List<AddressModel>> _controller =
      StreamController<List<AddressModel>>.broadcast();

  Stream<List<AddressModel>> get addressesStream => _controller.stream;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);

  void _update() {
    _controller.add(List.unmodifiable(_addresses));
  }

  void addAddress(AddressModel address) {
    _addresses.add(address);
    _update();
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((element) => element.id == id);
    _update();
  }

  void updateAddress(AddressModel updatedAddress) {
    final index = _addresses.indexWhere(
      (element) => element.id == updatedAddress.id,
    );
    if (index != -1) {
      _addresses[index] = updatedAddress;
      _update();
    }
  }
}
