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
    _subscription = _repository.addressesStream.listen((addresses) {
      if (!isClosed) {
        emit(AddressesLoaded(List.from(addresses)));
      }
    });
  }

  Future<void> getAddresses() async {
    emit(AddressesLoading());
    final result = await _repository.fetchAddresses();
    result.fold(
      (failure) => emit(AddressesError(failure.message)),
      (addressesList) => emit(AddressesLoaded(List.from(addressesList))),
    );
  }

  Future<void> addAddress(AddressModel address) async {
    emit(AddressesActionLoading());
    final result = await _repository.addAddress(address);
    result.fold(
      (failure) => emit(AddressesActionError(failure.message)),
      (_) => emit(AddressesActionSuccess()),
    );
  }

  Future<void> updateAddress(AddressModel updatedAddress) async {
    emit(AddressesActionLoading());
    final result = await _repository.updateAddress(updatedAddress);
    result.fold(
      (failure) => emit(AddressesActionError(failure.message)),
      (_) => emit(AddressesActionSuccess()),
    );
  }

  Future<void> deleteAddress(String id) async {
    emit(AddressesActionLoading());
    final result = await _repository.deleteAddress(id);
    result.fold(
      (failure) => emit(AddressesActionError(failure.message)),
      (_) => emit(AddressesActionSuccess()),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
