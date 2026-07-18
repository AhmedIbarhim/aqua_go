import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/config/local_storage/shared_prefs.dart';
import '../../../../core/constants.dart';
import '../../../../core/config/session/session_state.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../my_bookings/data/models/booking_response_model/breakdown.dart';

enum GiftStatus {
  ISSUED, // created, pending delivery
  DELIVERED, // recipient notified
  REDEEMED, // recipient has created a booking
  CANCELLED, // sender cancelled pre-delivery
  EXPIRED; // validity elapsed

  static GiftStatus? fromString(String? val) {
    if (val == null) return null;
    final upperVal = val.toUpperCase().replaceAll(' ', '_');
    return GiftStatus.values.firstWhere(
      (e) => e.name == upperVal,
      orElse: () => GiftStatus.ISSUED,
    );
  }

  String toJson() => name;

  String getStatusText(BuildContext context) {
    switch (this) {
      case GiftStatus.ISSUED:
        return LocaleKeys.gifts_status_received.tr(context: context);
      case GiftStatus.DELIVERED:
        return LocaleKeys.gifts_status_waiting_use.tr(context: context);
      case GiftStatus.REDEEMED:
        return LocaleKeys.gifts_status_used.tr(context: context);
      case GiftStatus.CANCELLED:
      case GiftStatus.EXPIRED:
        return LocaleKeys.gifts_status_expired.tr(context: context);
    }
  }

  Color getStatusBg(BuildContext context) {
    switch (this) {
      case GiftStatus.ISSUED:
        return context.colors.primary;
      case GiftStatus.DELIVERED:
        return context.colors.warning;
      case GiftStatus.REDEEMED:
        return context.colors.successSecondry;
      case GiftStatus.CANCELLED:
      case GiftStatus.EXPIRED:
        return context.colors.contentDisabled;
    }
  }

  Color getStatusTextColor(BuildContext context) {
    switch (this) {
      case GiftStatus.ISSUED:
      case GiftStatus.DELIVERED:
        return Colors.black;
      case GiftStatus.REDEEMED:
      case GiftStatus.CANCELLED:
      case GiftStatus.EXPIRED:
        return Colors.white;
    }
  }
}

class GiftModel {
  final String? giftId;
  final String? giftCode;
  final GiftStatus? status;
  final int? amountMinor;
  final Breakdown? breakdown;
  final String? recipientPhone;
  final String? recipientName;
  final String? themeId;
  final String? themeColor;
  final GiftThemeName? themeName;
  final String? messageText;
  final String? scheduledDeliveryAt;
  final String? deliveredAt;
  final String? validityEndsAt;
  final String? redeemedAt;
  final String? createdAt;
  final String? cardBrand;
  final List<GiftAddOn> addOns;

  // Compatibility fields for custom styling or legacy responses
  final String? senderName;
  final String? senderPhone;
  final String? themeIcon;
  final String? serviceNameAr;
  final String? serviceNameEn;
  final String? packageNameAr;
  final String? packageNameEn;

  GiftModel({
    this.giftId,
    this.giftCode,
    this.status,
    this.amountMinor,
    this.breakdown,
    this.recipientPhone,
    this.recipientName,
    this.themeId,
    this.themeColor,
    this.themeName,
    this.messageText,
    this.scheduledDeliveryAt,
    this.deliveredAt,
    this.validityEndsAt,
    this.redeemedAt,
    this.createdAt,
    this.cardBrand,
    this.addOns = const [],
    this.senderName,
    this.senderPhone,
    this.themeIcon,
    this.serviceNameAr,
    this.serviceNameEn,
    this.packageNameAr,
    this.packageNameEn,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      giftId: json['giftId'] as String? ?? json['id'] as String?,
      giftCode: json['giftCode'] as String? ?? json['code'] as String?,
      status: GiftStatus.fromString(json['status'] as String?),
      amountMinor:
          json['amountMinor'] as int? ?? json['totalAmountMinor'] as int?,
      breakdown: json['breakdown'] != null
          ? Breakdown.fromJson(json['breakdown'] as Map<String, dynamic>)
          : null,
      recipientPhone: json['recipientPhone'] as String?,
      recipientName: json['recipientName'] as String?,
      themeId: json['themeId'] as String?,
      themeColor: json['themeColor'] as String?,
      themeName: json['themeName'] != null
          ? GiftThemeName.fromJson(json['themeName'] as Map<String, dynamic>)
          : null,
      messageText: json['messageText'] as String?,
      scheduledDeliveryAt: json['scheduledDeliveryAt'] as String?,
      deliveredAt: json['deliveredAt'] as String?,
      validityEndsAt:
          json['validityEndsAt'] as String? ?? json['validUntil'] as String?,
      redeemedAt: json['redeemedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      cardBrand: json['cardBrand'] as String?,
      addOns: json['addOns'] != null
          ? (json['addOns'] as List)
              .map((e) => GiftAddOn.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      senderName: json['senderName'] as String?,
      senderPhone: json['senderPhone'] as String?,
      themeIcon: json['themeIcon'] as String?,
      serviceNameAr: json['serviceNameAr'] as String?,
      serviceNameEn: json['serviceNameEn'] as String?,
      packageNameAr: json['packageNameAr'] as String?,
      packageNameEn: json['packageNameEn'] as String?,
    );
  }

  // --- UI Compatibility Helpers ---
  String? get id => giftId;
  String? get code => giftCode;
  String? get validUntil => validityEndsAt;
  int? get totalAmountMinor => amountMinor;
  String? get message => messageText;

  String get title {
    if (themeName != null) {
      return CacheClient.getString(kLanguage, defaultValue: kArabicLang) ==
              kArabicLang
          ? themeName!.ar
          : themeName!.en;
    }
    final hasPackage = (packageNameAr != null || packageNameEn != null);
    if (hasPackage) {
      return CacheClient.getString(kLanguage, defaultValue: kArabicLang) ==
              kArabicLang
          ? (packageNameAr ?? serviceNameAr ?? '')
          : (packageNameEn ?? serviceNameEn ?? '');
    }
    final isAr =
        CacheClient.getString(kLanguage, defaultValue: kArabicLang) ==
            kArabicLang;
    final amount = (amountMinor ?? 0) / 100.0;
    return isAr
        ? 'بطاقة هدية بقيمة ${amount.toStringAsFixed(0)} ر.س'
        : 'Gift Card worth ${amount.toStringAsFixed(0)} SAR';
  }

  double get totalAmount => (amountMinor ?? 0) / 100.0;

  bool get isSent {
    final userPhone = currentUser.value?.phone;
    if (userPhone == null || recipientPhone == null) return true;

    final digitsUser = userPhone.replaceAll(RegExp(r'\D'), '');
    final digitsRecipient = recipientPhone!.replaceAll(RegExp(r'\D'), '');

    if (digitsUser.isEmpty || digitsRecipient.isEmpty) return true;

    if (digitsUser.length >= 9 && digitsRecipient.length >= 9) {
      final suffixUser = digitsUser.substring(digitsUser.length - 9);
      final suffixRecipient = digitsRecipient.substring(
        digitsRecipient.length - 9,
      );
      return suffixUser != suffixRecipient;
    }

    return digitsUser != digitsRecipient;
  }

  String get formattedExpiryDate {
    final dateStr = validityEndsAt;
    if (dateStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }
}

class GiftThemeName {
  final String ar;
  final String en;

  GiftThemeName({
    required this.ar,
    required this.en,
  });

  factory GiftThemeName.fromJson(Map<String, dynamic> json) {
    return GiftThemeName(
      ar: json['ar'] as String? ?? '',
      en: json['en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ar': ar,
      'en': en,
    };
  }
}

class GiftAddOn {
  final String addonId;
  final String nameAr;
  final String nameEn;
  final int priceMinor;
  final String currency;

  GiftAddOn({
    required this.addonId,
    required this.nameAr,
    required this.nameEn,
    required this.priceMinor,
    required this.currency,
  });

  factory GiftAddOn.fromJson(Map<String, dynamic> json) {
    return GiftAddOn(
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
