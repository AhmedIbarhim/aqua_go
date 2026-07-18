import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/wallet_repository.dart';
import '../../data/models/loyalty_balance_model.dart';
import '../../data/models/loyalty_ledger_response_model.dart';
import '../../data/models/points_transaction_model.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;
  bool _isLoadingMore = false;

  WalletCubit(this._repository) : super(WalletInitial());

  bool get isLoadingMore => _isLoadingMore;

  Future<void> fetchWallet({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(WalletLoading());
    }

    final results = await Future.wait([
      _repository.getWalletBalance(),
      _repository.getWalletLedger(limit: 20),
    ]);

    final balanceResult = results[0];
    final ledgerResult = results[1];

    if (balanceResult.isLeft()) {
      final failure = balanceResult.fold((f) => f, (_) => null)!;
      emit(WalletFailure(failure.message));
      return;
    }

    final balanceModel = balanceResult.fold(
      (_) => null,
      (r) => r as LoyaltyBalanceModel,
    )!;

    final ledgerModel = ledgerResult.fold(
      (failure) => null,
      (r) => r as LoyaltyLedgerResponseModel,
    );

    final List<PointsTransactionModel> txs = ledgerModel != null
        ? ledgerModel.items
        : balanceModel.recentEntries;
    final String? nextCursor = ledgerModel?.nextCursor;
    final bool hasReachedMax = nextCursor == null || nextCursor.isEmpty;

    emit(
      WalletSuccess(
        balanceModel: balanceModel,
        transactions: txs,
        nextCursor: nextCursor,
        hasReachedMax: hasReachedMax,
      ),
    );
  }

  Future<void> loadMoreTransactions() async {
    final currentState = state;
    if (currentState is! WalletSuccess ||
        _isLoadingMore ||
        currentState.hasReachedMax) {
      return;
    }

    _isLoadingMore = true;

    final result = await _repository.getWalletLedger(
      limit: 20,
      cursor: currentState.nextCursor,
    );

    result.fold(
      (failure) {
        _isLoadingMore = false;
      },
      (response) {
        _isLoadingMore = false;
        emit(
          currentState.copyWith(
            transactions: [...currentState.transactions, ...response.items],
            nextCursor: response.nextCursor,
            hasReachedMax:
                response.nextCursor == null || response.nextCursor!.isEmpty,
          ),
        );
      },
    );
  }
}
