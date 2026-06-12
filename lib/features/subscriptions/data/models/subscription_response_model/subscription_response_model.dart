import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package_snapshot.dart';
import 'subscription_breakdown.dart';
import 'subscription_included_allowance.dart';
import 'subscription_wash.dart';

class SubscriptionResponseModel {
  final String id;
  final String customerId;
  final String packageId;
  final String status;
  final int totalWashes;
  final int consumedWashes;
  final int? washesRemaining;
  final int packagePriceMinor;
  final String currency;
  final String validityStartsAt;
  final String validityEndsAt;
  final String purchasedAt;
  final String? cancelledAt;
  final String? cancelReason;
  final int? refundedMinor;
  final String? refundStatus;
  final PackageSnapshot packageSnapshot;
  final String? referenceNumber;
  final SubscriptionBreakdown? breakdown;
  final List<SubscriptionIncludedAllowance> includedAllowances;
  final List<SubscriptionWash> washes;

  SubscriptionResponseModel({
    required this.id,
    required this.customerId,
    required this.packageId,
    required this.status,
    required this.totalWashes,
    required this.consumedWashes,
    this.washesRemaining,
    required this.packagePriceMinor,
    required this.currency,
    required this.validityStartsAt,
    required this.validityEndsAt,
    required this.purchasedAt,
    this.cancelledAt,
    this.cancelReason,
    this.refundedMinor,
    this.refundStatus,
    required this.packageSnapshot,
    this.referenceNumber,
    this.breakdown,
    this.includedAllowances = const [],
    this.washes = const [],
  });

  // Dynamic getters for compatibility with UI
  String get title {
    final isArabic =
        CacheClient.getString(kLanguage, defaultValue: kArabicLang) ==
        kArabicLang;
    return isArabic ? packageSnapshot.nameAr : packageSnapshot.nameEn;
  }

  String get description {
    final isArabic =
        CacheClient.getString(kLanguage, defaultValue: kArabicLang) ==
        kArabicLang;
    return isArabic
        ? '$remainingWashes غسلة متبقية'
        : '$remainingWashes washes left';
  }

  String get image => 'assets/images/gift_demo.png';

  int get remainingWashes => washesRemaining ?? (totalWashes - consumedWashes);

  DateTime get expiryDate =>
      DateTime.tryParse(validityEndsAt) ?? DateTime.now();

  factory SubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponseModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      packageId: json['packageId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalWashes:
          (json['washesTotal'] ?? json['totalWashes'] as num?)?.toInt() ?? 0,
      consumedWashes:
          (json['washesConsumed'] ?? json['consumedWashes'] as num?)?.toInt() ??
          0,
      washesRemaining: (json['washesRemaining'] as num?)?.toInt(),
      packagePriceMinor: (json['packagePriceMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? '',
      validityStartsAt: json['validityStartsAt'] as String? ?? '',
      validityEndsAt: json['validityEndsAt'] as String? ?? '',
      purchasedAt: json['purchasedAt'] as String? ?? '',
      cancelledAt: json['cancelledAt'] as String?,
      cancelReason: json['cancelReason'] as String?,
      refundedMinor: (json['refundedMinor'] as num?)?.toInt(),
      refundStatus: json['refundStatus'] as String?,
      packageSnapshot: PackageSnapshot.fromJson(
        (json['packageInfo'] ?? json['packageSnapshot'] ?? {})
            as Map<String, dynamic>,
      ),
      referenceNumber: json['referenceNumber'] as String?,
      breakdown: json['breakdown'] != null
          ? SubscriptionBreakdown.fromJson(
              json['breakdown'] as Map<String, dynamic>,
            )
          : null,
      includedAllowances:
          (json['includedAllowances'] as List<dynamic>?)
              ?.map(
                (e) => SubscriptionIncludedAllowance.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      washes:
          (json['washes'] as List<dynamic>?)
              ?.map((e) => SubscriptionWash.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'packageId': packageId,
      'status': status,
      'washesTotal': totalWashes,
      'washesConsumed': consumedWashes,
      if (washesRemaining != null) 'washesRemaining': washesRemaining,
      'packagePriceMinor': packagePriceMinor,
      'currency': currency,
      'validityStartsAt': validityStartsAt,
      'validityEndsAt': validityEndsAt,
      'purchasedAt': purchasedAt,
      'cancelledAt': cancelledAt,
      'cancelReason': cancelReason,
      'refundedMinor': refundedMinor,
      'refundStatus': refundStatus,
      'packageInfo': packageSnapshot.toJson(),
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      if (breakdown != null) 'breakdown': breakdown!.toJson(),
      'includedAllowances': includedAllowances.map((e) => e.toJson()).toList(),
      'washes': washes.map((e) => e.toJson()).toList(),
    };
  }
}
