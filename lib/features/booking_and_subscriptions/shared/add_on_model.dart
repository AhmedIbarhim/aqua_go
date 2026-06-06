import '../../my_bookings/data/models/booking_response_model/breakdown.dart';

class AddOnModel {
  String? id;
  String? nameAr;
  String? nameEn;
  int? priceMinor;
  String? currency;
  String? imageUrl;
  Breakdown? breakdown;

  AddOnModel(
      {this.id,
      this.nameAr,
      this.nameEn,
      this.priceMinor,
      this.currency,
      this.imageUrl,
      this.breakdown});

  AddOnModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameAr = json['nameAr'];
    nameEn = json['nameEn'];
    priceMinor = json['priceMinor'];
    currency = json['currency'];
    imageUrl = json['imageUrl'];
    breakdown = json['breakdown'] != null
        ? Breakdown.fromJson(json['breakdown'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nameAr'] = nameAr;
    data['nameEn'] = nameEn;
    data['priceMinor'] = priceMinor;
    data['currency'] = currency;
    data['imageUrl'] = imageUrl;
    if (breakdown != null) {
      data['breakdown'] = breakdown!.toJson();
    }
    return data;
  }

  double get price => breakdown != null ? breakdown!.gross : ((priceMinor ?? 0) / 100);
}

