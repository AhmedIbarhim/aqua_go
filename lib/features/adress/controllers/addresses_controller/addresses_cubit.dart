import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/address_model.dart';

part 'addresses_state.dart';

class AddressesCubit extends Cubit<AddressesState> {
  static final AddressesCubit _instance = AddressesCubit._internal();
  factory AddressesCubit() => _instance;
  AddressesCubit._internal() : super(AddressesInitial());

  final List<AddressModel> _addresses = [];

  void getAddresses() {
    emit(AddressesLoaded(List.from(_addresses)));
  }

  void addAddress(AddressModel address) {
    _addresses.add(address);
    emit(AddressesLoaded(List.from(_addresses)));
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((element) => element.id == id);
    emit(AddressesLoaded(List.from(_addresses)));
  }

  void updateAddress(AddressModel updatedAddress) {
    final index = _addresses.indexWhere(
      (element) => element.id == updatedAddress.id,
    );
    if (index != -1) {
      _addresses[index] = updatedAddress;
      emit(AddressesLoaded(List.from(_addresses)));
    }
  }
}
