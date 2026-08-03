import 'points_transaction_model.dart';

class LoyaltyLedgerResponseModel {
  final List<PointsTransactionModel> items;
  final String? nextCursor;
  final int totalMatching;

  LoyaltyLedgerResponseModel({
    required this.items,
    this.nextCursor,
    required this.totalMatching,
  });

  factory LoyaltyLedgerResponseModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List?;
    return LoyaltyLedgerResponseModel(
      items: itemsList != null
          ? itemsList
              .map((e) => PointsTransactionModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      nextCursor: json['nextCursor'] as String?,
      totalMatching: json['totalMatching'] as int? ?? 0,
    );
  }
}
