import 'package:equatable/equatable.dart';
import '../../data/models/loyalty_balance_model.dart';
import '../../data/models/points_transaction_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletSuccess extends WalletState {
  final LoyaltyBalanceModel balanceModel;
  final List<PointsTransactionModel> transactions;
  final String? nextCursor;
  final bool hasReachedMax;

  const WalletSuccess({
    required this.balanceModel,
    required this.transactions,
    this.nextCursor,
    required this.hasReachedMax,
  });

  WalletSuccess copyWith({
    LoyaltyBalanceModel? balanceModel,
    List<PointsTransactionModel>? transactions,
    String? nextCursor,
    bool? hasReachedMax,
  }) {
    return WalletSuccess(
      balanceModel: balanceModel ?? this.balanceModel,
      transactions: transactions ?? this.transactions,
      nextCursor: nextCursor ?? this.nextCursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        balanceModel,
        transactions,
        nextCursor,
        hasReachedMax,
      ];
}

class WalletFailure extends WalletState {
  final String errMessage;

  const WalletFailure(this.errMessage);

  @override
  List<Object?> get props => [errMessage];
}
