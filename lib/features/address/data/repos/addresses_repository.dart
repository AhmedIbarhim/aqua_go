import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../models/address_model.dart';
import '../data_sources/addresses_remote_data_source.dart';

class AddressesRepository {
  final AddressesRemoteDataSource _addressesService;

  AddressesRepository(this._addressesService);

  Future<Either<Failure, List<AddressModel>>> fetchAddresses() async {
    final result = await _addressesService.getAddresses();
    return result.fold((failure) => Left(failure), (data) {
      if (data != null) {
        try {
          final List<dynamic> list = data as List<dynamic>;
          final parsedAddresses = list
              .map(
                (json) => AddressModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          return Right(parsedAddresses);
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
    return result.fold((failure) => Left(failure), (responseData) {
      if (responseData != null) {
        final addressJson = responseData as Map<String, dynamic>;
        final newAddress = AddressModel.fromJson(addressJson);

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
    return result.fold((failure) => Left(failure), (responseData) {
      final Map<String, dynamic> addressJson =
          (responseData != null && responseData is Map)
          ? responseData as Map<String, dynamic>
          : address.toJson();

      final updatedAddress = AddressModel.fromJson(addressJson);

      return Right(updatedAddress);
    });
  }

  Future<Either<Failure, void>> deleteAddress(String id) async {
    final result = await _addressesService.deleteAddress(id);
    return result.fold((failure) => Left(failure), (_) {
      return const Right(null);
    });
  }
}
