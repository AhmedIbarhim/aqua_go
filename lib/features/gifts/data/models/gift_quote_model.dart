import '../../../my_bookings/data/models/booking_response_model/breakdown.dart';

class GiftQuoteModel {
  final int faceMinor;
  final Breakdown? breakdown;
  final int maxApplicablePoints;
  final int pointsApplied;
  final bool pointsClamped;
  final int pointsDiscountMinor;
  final int cardChargeMinor;
  final String currency;

  GiftQuoteModel({
    required this.faceMinor,
    this.breakdown,
    required this.maxApplicablePoints,
    required this.pointsApplied,
    required this.pointsClamped,
    required this.pointsDiscountMinor,
    required this.cardChargeMinor,
    required this.currency,
  });

  factory GiftQuoteModel.fromJson(Map<String, dynamic> json) => GiftQuoteModel(
        faceMinor: json['faceMinor'] as int,
        breakdown: json['breakdown'] != null
            ? Breakdown.fromJson(json['breakdown'] as Map<String, dynamic>)
            : null,
        maxApplicablePoints: json['maxApplicablePoints'] as int,
        pointsApplied: json['pointsApplied'] as int,
        pointsClamped: json['pointsClamped'] as bool,
        pointsDiscountMinor: json['pointsDiscountMinor'] as int,
        cardChargeMinor: json['cardChargeMinor'] as int,
        currency: json['currency'] as String,
      );

  Map<String, dynamic> toJson() => {
        'faceMinor': faceMinor,
        if (breakdown != null) 'breakdown': breakdown!.toJson(),
        'maxApplicablePoints': maxApplicablePoints,
        'pointsApplied': pointsApplied,
        'pointsClamped': pointsClamped,
        'pointsDiscountMinor': pointsDiscountMinor,
        'cardChargeMinor': cardChargeMinor,
        'currency': currency,
      };

  // --- UI Helpers ---
  double get face => faceMinor / 100.0;
  double get pointsDiscount => pointsDiscountMinor / 100.0;
  double get cardCharge => cardChargeMinor / 100.0;
}
