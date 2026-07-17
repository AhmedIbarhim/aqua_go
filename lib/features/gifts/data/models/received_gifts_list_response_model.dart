import 'package:aqua_go/features/home/data/models/service_model.dart';

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

class ReceivedGiftModel {
  final String giftId;
  final String giftCode;
  final String themeId;
  final String? themeImageUrl;
  final String? themeColor;
  final ReceivedGiftThemeName? themeName;
  final String senderName;
  final String? senderPhone;
  final String messageText;
  final int amountMinor;
  final ReceivedGiftServiceName serviceName;
  final String? serviceId;
  final ServiceModel? service;
  final String status;
  final DateTime validityEndsAt;
  final DateTime deliveredAt;
  final List<ReceivedGiftAddOn> addOns;

  ReceivedGiftModel({
    required this.giftId,
    required this.giftCode,
    required this.themeId,
    this.themeImageUrl,
    this.themeColor,
    this.themeName,
    required this.senderName,
    this.senderPhone,
    required this.messageText,
    required this.amountMinor,
    required this.serviceName,
    this.serviceId,
    this.service,
    required this.status,
    required this.validityEndsAt,
    required this.deliveredAt,
    required this.addOns,
  });

  factory ReceivedGiftModel.fromJson(Map<String, dynamic> json) {
    return ReceivedGiftModel(
      giftId: json['giftId'] as String,
      giftCode: json['giftCode'] as String,
      themeId: json['themeId'] as String,
      themeImageUrl: json['themeImageUrl'] as String?,
      themeColor: json['themeColor'] as String?,
      themeName: json['themeName'] != null
          ? ReceivedGiftThemeName.fromJson(
              json['themeName'] as Map<String, dynamic>,
            )
          : null,
      senderName: json['senderName'] as String,
      senderPhone: json['senderPhone'] as String?,
      messageText: json['messageText'] as String,
      amountMinor: json['amountMinor'] as int,
      serviceName: ReceivedGiftServiceName.fromJson(
        json['serviceName'] as Map<String, dynamic>,
      ),
      serviceId: json['serviceId'] as String?,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String,
      validityEndsAt: DateTime.parse(json['validityEndsAt'] as String),
      deliveredAt: DateTime.parse(json['deliveredAt'] as String),
      addOns: json['addOns'] != null
          ? (json['addOns'] as List)
                .map(
                  (e) => ReceivedGiftAddOn.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : <ReceivedGiftAddOn>[],
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'giftId': giftId,
  //     'giftCode': giftCode,
  //     'themeId': themeId,
  //     'themeImageUrl': themeImageUrl,
  //     'themeColor': themeColor,
  //     if (themeName != null) 'themeName': themeName!.toJson(),
  //     'senderName': senderName,
  //     if (senderPhone != null) 'senderPhone': senderPhone,
  //     'messageText': messageText,
  //     'amountMinor': amountMinor,
  //     'serviceName': serviceName.toJson(),
  //     if (serviceId != null) 'serviceId': serviceId,
  //     if (service != null) 'service': service!.toJson(),
  //     'status': status,
  //     'validityEndsAt': validityEndsAt.toIso8601String(),
  //     'deliveredAt': deliveredAt.toIso8601String(),
  //     'addOns': addOns.map((e) => e.toJson()).toList(),
  //   };
  // }

  double get amount => amountMinor / 100.0;
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
