import 'received_gift_model.dart';

class ReceivedGiftsListResponseModel {
  final List<ReceivedGiftModel> items;
  final String? nextCursor;
  final int totalMatching;

  ReceivedGiftsListResponseModel({
    required this.items,
    this.nextCursor,
    required this.totalMatching,
  });

  factory ReceivedGiftsListResponseModel.fromJson(Map<String, dynamic> json) {
    return ReceivedGiftsListResponseModel(
      items: json['items'] != null
          ? (json['items'] as List)
                .map(
                  (i) => ReceivedGiftModel.fromJson(i as Map<String, dynamic>),
                )
                .toList()
          : <ReceivedGiftModel>[],
      nextCursor: json['nextCursor'] as String?,
      totalMatching: (json['totalMatching'] as num?)?.toInt() ?? 0,
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'items': items.map((i) => i.toJson()).toList(),
  //     if (nextCursor != null) 'nextCursor': nextCursor,
  //     'totalMatching': totalMatching,
  //   };
  // }
}

class ReceivedGiftServiceName {
  final String ar;
  final String en;

  ReceivedGiftServiceName({required this.ar, required this.en});

  factory ReceivedGiftServiceName.fromJson(Map<String, dynamic> json) {
    return ReceivedGiftServiceName(
      ar: json['ar'] as String? ?? '',
      en: json['en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ar': ar, 'en': en};
  }
}

class ReceivedGiftThemeName {
  final String ar;
  final String en;

  ReceivedGiftThemeName({required this.ar, required this.en});

  factory ReceivedGiftThemeName.fromJson(Map<String, dynamic> json) {
    return ReceivedGiftThemeName(
      ar: json['ar'] as String? ?? '',
      en: json['en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ar': ar, 'en': en};
  }
}

class ReceivedGiftAddOn {
  final String addonId;
  final String nameAr;
  final String nameEn;
  final int priceMinor;
  final String currency;

  ReceivedGiftAddOn({
    required this.addonId,
    required this.nameAr,
    required this.nameEn,
    required this.priceMinor,
    required this.currency,
  });

  factory ReceivedGiftAddOn.fromJson(Map<String, dynamic> json) {
    return ReceivedGiftAddOn(
      addonId: json['addonId'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      priceMinor: (json['priceMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addonId': addonId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'priceMinor': priceMinor,
      'currency': currency,
    };
  }
}
