import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

class AddressesRemoteDataSource {
  final APIClient _apiClient;

  AddressesRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getAddresses() {
    return _apiClient.get(Endpoints.myAddresses);
  }

  Future<Either<Failure, dynamic>> addAddress(Map<String, dynamic> data) {
    return _apiClient.post(Endpoints.myAddresses, data: data);
  }

  Future<Either<Failure, dynamic>> updateAddress(
    String addressId,
    Map<String, dynamic> data,
  ) {
    return _apiClient.patch(Endpoints.myAddress(addressId), data: data);
  }

  Future<Either<Failure, dynamic>> deleteAddress(String addressId) {
    return _apiClient.delete(Endpoints.myAddress(addressId));
  }
}
