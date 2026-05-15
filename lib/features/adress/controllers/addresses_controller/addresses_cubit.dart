import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/address_model.dart';
import '../../data/repos/addresses_repository.dart';

part 'addresses_state.dart';

class AddressesCubit extends Cubit<AddressesState> {
  final AddressesRepository _repository;
  StreamSubscription? _subscription;

  AddressesCubit({required AddressesRepository repository})
      : _repository = repository,
        super(AddressesInitial()) {
    // Listen to repository changes to keep state in sync
    _subscription = _repository.addressesStream.listen((addresses) {
      if (!isClosed) {
        emit(AddressesLoaded(addresses));
      }
    });
  }

  void getAddresses() {
    emit(AddressesLoaded(_repository.addresses));
  }

  void addAddress(AddressModel address) {
    _repository.addAddress(address);
  }

  void deleteAddress(String id) {
    _repository.deleteAddress(id);
  }

  void updateAddress(AddressModel updatedAddress) {
    _repository.updateAddress(updatedAddress);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
