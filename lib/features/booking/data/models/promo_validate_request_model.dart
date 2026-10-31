class PromoValidateRequestModel {
  final String code;
  final String packageId;
  final double lat;
  final double lng;

  PromoValidateRequestModel({
    required this.code,
    required this.packageId,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'packageId': packageId,
    'lat': lat,
    'lng': lng,
  };
}
