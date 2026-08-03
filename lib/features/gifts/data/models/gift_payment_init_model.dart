import 'package:aqua_go/features/booking/data/models/payment_init_model.dart';

class GiftPaymentInitModel {
  final int amountMinor;
  final String currency;
  final String givenId;
  final Map<String, dynamic> metadata;

  GiftPaymentInitModel({
    required this.amountMinor,
    required this.currency,
    required this.givenId,
    required this.metadata,
  });

  factory GiftPaymentInitModel.fromJson(Map<String, dynamic> json) {
    return GiftPaymentInitModel(
      amountMinor: json['amountMinor'] as int,
      currency: (json['currency'] as String?) ?? 'SAR',
      givenId: json['givenId'] as String,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amountMinor': amountMinor,
      'currency': currency,
      'givenId': givenId,
      'metadata': metadata,
    };
  }

  PaymentInitModel toPaymentInitModel() {
    return PaymentInitModel(
      amountMinor: amountMinor,
      givenId: givenId,
      currency: currency,
      metadata: metadata,
    );
  }
}
