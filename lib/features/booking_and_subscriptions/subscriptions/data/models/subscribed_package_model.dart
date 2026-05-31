import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/features/home/data/models/package_model.dart';

class SubscribedPackageModel {
  final String id;
  final String customerId;
  final String packageId;
  final String status;
  final int totalWashes;
  final int consumedWashes;
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

  SubscribedPackageModel({
    required this.id,
    required this.customerId,
    required this.packageId,
    required this.status,
    required this.totalWashes,
    required this.consumedWashes,
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
  });

  // Dynamic getters for compatibility with UI
  String get title {
    final lang = CacheClient.getString(kLanguage);
    return lang == 'en' ? packageSnapshot.nameEn : packageSnapshot.nameAr;
  }

  String get description {
    final lang = CacheClient.getString(kLanguage);
    return lang == 'en'
        ? '${packageSnapshot.numWashes} washes left'
        : '${packageSnapshot.numWashes} غسلة متبقية';
  }

  String get image => 'assets/images/gift_demo.png';

  int get remainingWashes => totalWashes - consumedWashes;

  DateTime get expiryDate => DateTime.tryParse(validityEndsAt) ?? DateTime.now();

  factory SubscribedPackageModel.fromJson(Map<String, dynamic> json) {
    return SubscribedPackageModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      packageId: json['packageId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalWashes: json['totalWashes'] as int? ?? 0,
      consumedWashes: json['consumedWashes'] as int? ?? 0,
      packagePriceMinor: json['packagePriceMinor'] as int? ?? 0,
      currency: json['currency'] as String? ?? '',
      validityStartsAt: json['validityStartsAt'] as String? ?? '',
      validityEndsAt: json['validityEndsAt'] as String? ?? '',
      purchasedAt: json['purchasedAt'] as String? ?? '',
      cancelledAt: json['cancelledAt'] as String?,
      cancelReason: json['cancelReason'] as String?,
      refundedMinor: json['refundedMinor'] as int?,
      refundStatus: json['refundStatus'] as String?,
      packageSnapshot: PackageSnapshot.fromJson(
        json['packageSnapshot'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'packageId': packageId,
      'status': status,
      'totalWashes': totalWashes,
      'consumedWashes': consumedWashes,
      'packagePriceMinor': packagePriceMinor,
      'currency': currency,
      'validityStartsAt': validityStartsAt,
      'validityEndsAt': validityEndsAt,
      'purchasedAt': purchasedAt,
      'cancelledAt': cancelledAt,
      'cancelReason': cancelReason,
      'refundedMinor': refundedMinor,
      'refundStatus': refundStatus,
      'packageSnapshot': packageSnapshot.toJson(),
    };
  }
}

class PackageSnapshot {
  final String nameAr;
  final String nameEn;
  final int numWashes;
  final int validityDays;
  final bool allowScheduleLater;
  final List<String> bundledServiceIds;
  final List<PackageAddonModel> includedAddons;
  final List<PackageAddonModel> optionalAddons;
  final bool isPopular;
  final int carsPerWash;

  PackageSnapshot({
    required this.nameAr,
    required this.nameEn,
    required this.numWashes,
    required this.validityDays,
    required this.allowScheduleLater,
    required this.bundledServiceIds,
    required this.includedAddons,
    required this.optionalAddons,
    required this.isPopular,
    required this.carsPerWash,
  });

  factory PackageSnapshot.fromJson(Map<String, dynamic> json) {
    return PackageSnapshot(
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      numWashes: json['numWashes'] as int? ?? 0,
      validityDays: json['validityDays'] as int? ?? 0,
      allowScheduleLater: json['allowScheduleLater'] as bool? ?? true,
      bundledServiceIds: (json['bundledServiceIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      includedAddons: (json['includedAddons'] as List<dynamic>?)
              ?.map((e) => PackageAddonModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      optionalAddons: (json['optionalAddons'] as List<dynamic>?)
              ?.map((e) => PackageAddonModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isPopular: json['isPopular'] as bool? ?? false,
      carsPerWash: json['carsPerWash'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'numWashes': numWashes,
      'validityDays': validityDays,
      'allowScheduleLater': allowScheduleLater,
      'bundledServiceIds': bundledServiceIds,
      'includedAddons': includedAddons.map((e) => e.toJson()).toList(),
      'optionalAddons': optionalAddons.map((e) => e.toJson()).toList(),
      'isPopular': isPopular,
      'carsPerWash': carsPerWash,
    };
  }
}
