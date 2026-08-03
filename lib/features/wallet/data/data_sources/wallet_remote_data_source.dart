import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:dartz/dartz.dart';

class WalletRemoteDataSource {
  final APIClient _apiClient;

  WalletRemoteDataSource(this._apiClient);

  Future<Either<Failure, dynamic>> getWalletBalance() {
    return _apiClient.get(Endpoints.wallet);
  }

  Future<Either<Failure, dynamic>> getWalletLedger({
    int limit = 20,
    String? cursor,
  }) {
    final Map<String, dynamic> queryParameters = {'limit': limit};
    if (cursor != null && cursor.isNotEmpty) {
      queryParameters['cursor'] = cursor;
    }
    return _apiClient.get(
      Endpoints.walletLedger,
      queryParameters: queryParameters,
    );
  }
}
