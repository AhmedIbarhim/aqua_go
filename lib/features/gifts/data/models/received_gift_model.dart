import '../../../home/data/models/service_model.dart';
import 'received_gifts_list_response_model.dart';

class ReceivedGiftModel {
  final String giftId;
  final String giftCode;
  final String referenceNumber;
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
    required this.referenceNumber,
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
      referenceNumber: json['referenceNumber'] as String,
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
