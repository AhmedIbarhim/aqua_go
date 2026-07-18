import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/wallet/data/data_sources/wallet_remote_data_source.dart';
import 'package:aqua_go/features/wallet/data/models/loyalty_balance_model.dart';
import 'package:aqua_go/features/wallet/data/models/loyalty_ledger_response_model.dart';
import 'package:dartz/dartz.dart';

class WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepository(this._remoteDataSource);

  Future<Either<Failure, LoyaltyBalanceModel>> getWalletBalance() async {
    final result = await _remoteDataSource.getWalletBalance();
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final balanceModel = LoyaltyBalanceModel.fromJson(
              data as Map<String, dynamic>,
            );
            return Right(balanceModel);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load wallet balance'));
      },
    );
  }

  Future<Either<Failure, LoyaltyLedgerResponseModel>> getWalletLedger({
    int limit = 20,
    String? cursor,
  }) async {
    final result = await _remoteDataSource.getWalletLedger(
      limit: limit,
      cursor: cursor,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data != null) {
          try {
            final ledgerModel = LoyaltyLedgerResponseModel.fromJson(
              data as Map<String, dynamic>,
            );
            return Right(ledgerModel);
          } catch (e) {
            return Left(ServerFailure('Parsing error: $e'));
          }
        }
        return const Left(ServerFailure('Failed to load wallet ledger'));
      },
    );
  }
}
