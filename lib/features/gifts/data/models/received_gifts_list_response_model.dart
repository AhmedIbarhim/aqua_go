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
              .map((i) => ReceivedGiftModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : <ReceivedGiftModel>[],
      nextCursor: json['nextCursor'] as String?,
      totalMatching: (json['totalMatching'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
      if (nextCursor != null) 'nextCursor': nextCursor,
      'totalMatching': totalMatching,
    };
  }
}

class ReceivedGiftModel {
  final String giftId;
  final String giftCode;
  final String themeId;
  final String? themeImageUrl;
  final String? themeColor;
  final String senderName;
  final String messageText;
  final int amountMinor;
  final ReceivedGiftServiceName serviceName;
  final String status;
  final DateTime validityEndsAt;
  final DateTime deliveredAt;

  ReceivedGiftModel({
    required this.giftId,
    required this.giftCode,
    required this.themeId,
    this.themeImageUrl,
    this.themeColor,
    required this.senderName,
    required this.messageText,
    required this.amountMinor,
    required this.serviceName,
    required this.status,
    required this.validityEndsAt,
    required this.deliveredAt,
  });

  factory ReceivedGiftModel.fromJson(Map<String, dynamic> json) {
    return ReceivedGiftModel(
      giftId: json['giftId'] as String,
      giftCode: json['giftCode'] as String,
      themeId: json['themeId'] as String,
      themeImageUrl: json['themeImageUrl'] as String?,
      themeColor: json['themeColor'] as String?,
      senderName: json['senderName'] as String,
      messageText: json['messageText'] as String,
      amountMinor: json['amountMinor'] as int,
      serviceName: ReceivedGiftServiceName.fromJson(
          json['serviceName'] as Map<String, dynamic>),
      status: json['status'] as String,
      validityEndsAt: DateTime.parse(json['validityEndsAt'] as String),
      deliveredAt: DateTime.parse(json['deliveredAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'giftId': giftId,
      'giftCode': giftCode,
      'themeId': themeId,
      'themeImageUrl': themeImageUrl,
      'themeColor': themeColor,
      'senderName': senderName,
      'messageText': messageText,
      'amountMinor': amountMinor,
      'serviceName': serviceName.toJson(),
      'status': status,
      'validityEndsAt': validityEndsAt.toIso8601String(),
      'deliveredAt': deliveredAt.toIso8601String(),
    };
  }

  double get amount => amountMinor / 100.0;
}

class ReceivedGiftServiceName {
  final String ar;
  final String en;

  ReceivedGiftServiceName({
    required this.ar,
    required this.en,
  });

  factory ReceivedGiftServiceName.fromJson(Map<String, dynamic> json) {
    return ReceivedGiftServiceName(
      ar: json['ar'] as String,
      en: json['en'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ar': ar,
      'en': en,
    };
  }
}
