import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/address_model.dart';
import '../data_sources/addresses_remote_data_source.dart';

class AddressesRepository {
  final AddressesRemoteDataSource _addressesService;
  final List<AddressModel> _addresses = [];
  final StreamController<List<AddressModel>> _controller =
      StreamController<List<AddressModel>>.broadcast();

  AddressesRepository(this._addressesService);

  Stream<List<AddressModel>> get addressesStream => _controller.stream;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);

  void _update() {
    _controller.add(List.unmodifiable(_addresses));
  }

  Future<Either<Failure, List<AddressModel>>> fetchAddresses() async {
    final result = await _addressesService.getAddresses();
    return result.fold((failure) => Left(failure), (response) {
      if (response.statusCode == 200 && response.data != null) {
        try {
          final List<dynamic> list = response.data as List<dynamic>;
          final parsedAddresses = list
              .map(
                (json) => AddressModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          _addresses.clear();
          _addresses.addAll(parsedAddresses);
          _update();
          return Right(_addresses);
        } catch (e) {
          return Left(ServerFailure('Parsing error: $e'));
        }
      }
      return const Left(ServerFailure('Failed to parse addresses response'));
    });
  }

  Future<Either<Failure, AddressModel>> addAddress(AddressModel address) async {
    final Map<String, dynamic> data = address.toJson();

    final result = await _addressesService.addAddress(data);
    return result.fold((failure) => Left(failure), (response) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final addressJson = response.data as Map<String, dynamic>;
        final newAddress = AddressModel.fromJson(addressJson);

        _addresses.add(newAddress);
        _update();
        return Right(newAddress);
      }
      return const Left(ServerFailure('Failed to save address details'));
    });
  }

  Future<Either<Failure, AddressModel>> updateAddress(
    AddressModel address,
  ) async {
    final Map<String, dynamic> data = address.toJson();

    final result = await _addressesService.updateAddress(address.id!, data);
    return result.fold((failure) => Left(failure), (response) {
      if (response.statusCode == 200 || response.statusCode == 204) {
        final Map<String, dynamic> addressJson =
            (response.data != null && response.data is Map)
            ? response.data as Map<String, dynamic>
            : address.toJson();

        final updatedAddress = AddressModel.fromJson(addressJson);

        final index = _addresses.indexWhere(
          (element) => element.id == address.id,
        );
        if (index != -1) {
          _addresses[index] = updatedAddress;
          _update();
        }
        return Right(updatedAddress);
      }
      return const Left(ServerFailure('Failed to update address details'));
    });
  }

  Future<Either<Failure, void>> deleteAddress(String id) async {
    final result = await _addressesService.deleteAddress(id);
    return result.fold((failure) => Left(failure), (response) {
      if (response.statusCode == 200 || response.statusCode == 204) {
        _addresses.removeWhere((element) => element.id == id);
        _update();
        return const Right(null);
      }
      return const Left(ServerFailure('Failed to remove address'));
    });
  }

  void dispose() {
    _controller.close();
  }
}
