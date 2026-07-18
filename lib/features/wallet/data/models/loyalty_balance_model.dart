import 'points_transaction_model.dart';

class LoyaltyBalanceModel {
  final int points;
  final int estimatedValueMinor;
  final int redemptionRateMinorPerPoint;
  final int earnMinorPerPoint;
  final int maxCoveragePct;
  final List<PointsTransactionModel> recentEntries;

  LoyaltyBalanceModel({
    required this.points,
    required this.estimatedValueMinor,
    required this.redemptionRateMinorPerPoint,
    required this.earnMinorPerPoint,
    required this.maxCoveragePct,
    required this.recentEntries,
  });

  factory LoyaltyBalanceModel.fromJson(Map<String, dynamic> json) {
    final recentEntriesList = json['recentEntries'] as List?;
    return LoyaltyBalanceModel(
      points: json['points'] as int? ?? 0,
      estimatedValueMinor: json['estimatedValueMinor'] as int? ?? 0,
      redemptionRateMinorPerPoint: json['redemptionRateMinorPerPoint'] as int? ?? 1,
      earnMinorPerPoint: json['earnMinorPerPoint'] as int? ?? 0,
      maxCoveragePct: json['maxCoveragePct'] as int? ?? 100,
      recentEntries: recentEntriesList != null
          ? recentEntriesList
              .map((e) => PointsTransactionModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}
