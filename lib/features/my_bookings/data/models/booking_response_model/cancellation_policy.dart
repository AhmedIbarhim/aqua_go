class CancellationPolicy {
  bool? isFreeNow;
  int? feeIfCancelledNowMinor;
  String? freeUntil;
  String? currency;

  CancellationPolicy({
    this.isFreeNow,
    this.feeIfCancelledNowMinor,
    this.freeUntil,
    this.currency,
  });

  CancellationPolicy.fromJson(Map<String, dynamic> json) {
    isFreeNow = json['isFreeNow'];
    feeIfCancelledNowMinor = json['feeIfCancelledNowMinor'];
    freeUntil = json['freeUntil'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isFreeNow'] = isFreeNow;
    data['feeIfCancelledNowMinor'] = feeIfCancelledNowMinor;
    data['freeUntil'] = freeUntil;
    data['currency'] = currency;
    return data;
  }
}
