import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../../core/config/local_storage/shared_prefs.dart';
import '../../../../core/constants.dart';
import '../../../../core/config/session/session_state.dart';
import '../../../../generated/locale_keys.g.dart';

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
  final String? recipientPhoneE164;
  final String? recipientName;
  final String? themeId;
  final String? scheduledDeliveryAt;
  final String? deliveredAt;
  final String? validityEndsAt;
  final String? redeemedAt;
  final String? createdAt;

  // Compatibility fields for custom styling or legacy responses
  final String? senderName;
  final String? senderPhone;
  final String? message;
  final String? serviceNameAr;
  final String? serviceNameEn;
  final String? packageNameAr;
  final String? packageNameEn;
  final String? themeIcon;

  GiftModel({
    this.giftId,
    this.giftCode,
    this.status,
    this.amountMinor,
    this.recipientPhoneE164,
    this.recipientName,
    this.themeId,
    this.scheduledDeliveryAt,
    this.deliveredAt,
    this.validityEndsAt,
    this.redeemedAt,
    this.createdAt,
    this.senderName,
    this.senderPhone,
    this.message,
    this.serviceNameAr,
    this.serviceNameEn,
    this.packageNameAr,
    this.packageNameEn,
    this.themeIcon,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      giftId: json['giftId'] as String? ?? json['id'] as String?,
      giftCode: json['giftCode'] as String? ?? json['code'] as String?,
      status: GiftStatus.fromString(json['status'] as String?),
      amountMinor:
          json['amountMinor'] as int? ?? json['totalAmountMinor'] as int?,
      recipientPhoneE164:
          json['recipientPhoneE164'] as String? ??
          json['recipientPhone'] as String?,
      recipientName: json['recipientName'] as String?,
      themeId: json['themeId'] as String?,
      scheduledDeliveryAt: json['scheduledDeliveryAt'] as String?,
      deliveredAt: json['deliveredAt'] as String?,
      validityEndsAt:
          json['validityEndsAt'] as String? ?? json['validUntil'] as String?,
      redeemedAt: json['redeemedAt'] as String?,
      createdAt: json['createdAt'] as String?,

      senderName: json['senderName'] as String?,
      senderPhone: json['senderPhone'] as String?,
      message: json['message'] as String? ?? json['messageText'] as String?,
      serviceNameAr: json['serviceNameAr'] as String?,
      serviceNameEn: json['serviceNameEn'] as String?,
      packageNameAr: json['packageNameAr'] as String?,
      packageNameEn: json['packageNameEn'] as String?,
      themeIcon: json['themeIcon'] as String?,
    );
  }

  // --- UI Compatibility Helpers ---
  String? get id => giftId;
  String? get code => giftCode;
  String? get recipientPhone => recipientPhoneE164;
  String? get validUntil => validityEndsAt;
  int? get totalAmountMinor => amountMinor;

  String get title {
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
    if (userPhone == null || recipientPhoneE164 == null) return true;

    final digitsUser = userPhone.replaceAll(RegExp(r'\D'), '');
    final digitsRecipient = recipientPhoneE164!.replaceAll(RegExp(r'\D'), '');

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
