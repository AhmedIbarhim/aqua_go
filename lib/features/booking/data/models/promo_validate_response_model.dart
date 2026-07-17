class PromoValidateResponseModel {
  final bool valid;
  final String code;
  final int discountMinor;
  final String? rejectionReason;

  PromoValidateResponseModel({
    required this.valid,
    required this.code,
    required this.discountMinor,
    this.rejectionReason,
  });

  factory PromoValidateResponseModel.fromJson(Map<String, dynamic> json) =>
      PromoValidateResponseModel(
        valid: json['valid'] as bool,
        code: json['code'] as String,
        discountMinor: json['discountMinor'] as int,
        rejectionReason: json['rejectionReason'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'valid': valid,
        'code': code,
        'discountMinor': discountMinor,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      };

  double get discount => discountMinor / 100.0;
}
