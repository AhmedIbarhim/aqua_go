import 'package:easy_localization/easy_localization.dart';
import '../../../../core/config/local_storage/shared_prefs.dart';
import '../../../../core/constants.dart';
import '../enums/booking_status_enum.dart';
import '../enums/booking_type_enum.dart';
import 'booking_response_model/booking_response_model.dart';

class BookingSummaryModel {
  final String? id;
  final String? customerId;
  final String? workerId;
  final String? addressLabel;
  final num? addressLat;
  final num? addressLng;
  final String? zoneId;
  final String? packageId;
  final BookingType? type;
  final BookingStatus? status;
  final String? scheduledAt;
  final String? createdAt;
  final String? updatedAt;
  final int? totalAmountMinor;
  final String? currency;
  final String? serviceNameAr;
  final String? serviceNameEn;
  final bool? isSubscription;
  final int? vehicleYear;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? plateMasked;
  final String? vehicleMakeLogoUrl;

  BookingSummaryModel({
    this.id,
    this.customerId,
    this.workerId,
    this.addressLabel,
    this.addressLat,
    this.addressLng,
    this.zoneId,
    this.packageId,
    this.type,
    this.status,
    this.scheduledAt,
    this.createdAt,
    this.updatedAt,
    this.totalAmountMinor,
    this.currency,
    this.serviceNameAr,
    this.serviceNameEn,
    this.isSubscription,
    this.vehicleYear,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleColor,
    this.plateMasked,
    this.vehicleMakeLogoUrl,
  });

  factory BookingSummaryModel.fromJson(Map<String, dynamic> json) {
    return BookingSummaryModel(
      id: json['id'] as String?,
      customerId: json['customerId'] as String?,
      workerId: json['workerId'] as String?,
      addressLabel: json['addressLabel'] as String?,
      addressLat: json['addressLat'] != null
          ? num.tryParse(json['addressLat'].toString())
          : (json['lat'] != null ? num.tryParse(json['lat'].toString()) : null),
      addressLng: json['addressLng'] != null
          ? num.tryParse(json['addressLng'].toString())
          : (json['lng'] != null ? num.tryParse(json['lng'].toString()) : null),
      zoneId: json['zoneId'] as String?,
      packageId: json['packageId'] as String?,
      type: BookingType.fromString(json['type'] as String?),
      status: BookingStatus.fromString(json['status'] as String?),
      scheduledAt: json['scheduledAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      totalAmountMinor: json['totalAmountMinor'] as int?,
      currency: json['currency'] as String?,
      serviceNameAr: json['serviceNameAr'] as String?,
      serviceNameEn: json['serviceNameEn'] as String?,
      isSubscription: json['isSubscription'] as bool?,
      vehicleYear: json['vehicleYear'] != null
          ? int.tryParse(json['vehicleYear'].toString())
          : null,
      vehicleMake: json['vehicleMake'] as String?,
      vehicleModel: json['vehicleModel'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      plateMasked:
          json['plateMasked'] ?? json['plateText'] ?? json['plate_masked'],
      vehicleMakeLogoUrl: json['vehicleMakeLogoUrl'] as String?,
    );
  }

  factory BookingSummaryModel.fromDetails(BookingResponseModel details) {
    return BookingSummaryModel(
      id: details.id,
      customerId: details.customerId,
      workerId: details.workerId,
      addressLabel: details.addressLabel,
      addressLat: details.addressLat,
      addressLng: details.addressLng,
      zoneId: details.zoneId,
      packageId: details.packageId,
      type: details.type,
      status: details.status,
      scheduledAt: details.scheduledAt,
      createdAt: details.createdAt,
      updatedAt: details.updatedAt,
      totalAmountMinor: details.totalAmountMinor,
      currency: details.currency,
      vehicleYear: details.vehicleYear,
      vehicleMake: details.vehicleMake,
      vehicleModel: details.vehicleModel,
      vehicleColor: details.vehicleColor,
      plateMasked: details.plateMasked,
      vehicleMakeLogoUrl: details.vehicleMakeLogoUrl,
      serviceNameEn: details.packageName?.en,
      serviceNameAr: details.packageName?.ar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'workerId': workerId,
      'addressLabel': addressLabel,
      'addressLat': addressLat,
      'addressLng': addressLng,
      'zoneId': zoneId,
      'packageId': packageId,
      'type': type?.name,
      'status': status?.name,
      'scheduledAt': scheduledAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'totalAmountMinor': totalAmountMinor,
      'currency': currency,
      'serviceNameAr': serviceNameAr,
      'serviceNameEn': serviceNameEn,
      'isSubscription': isSubscription,
      'vehicleYear': vehicleYear,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'plateMasked': plateMasked,
      'vehicleMakeLogoUrl': vehicleMakeLogoUrl,
    };
  }

  // Bridging mapper to details model
  BookingResponseModel toDetailsPlaceholder() {
    return BookingResponseModel(
      id: id,
      customerId: customerId,
      workerId: workerId,
      addressLabel: addressLabel,
      addressLat: addressLat,
      addressLng: addressLng,
      zoneId: zoneId,
      packageId: packageId,
      type: type,
      status: status,
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      totalAmountMinor: totalAmountMinor,
      currency: currency,
      vehicleYear: vehicleYear,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      vehicleColor: vehicleColor,
      plateMasked: plateMasked,
      vehicleMakeLogoUrl: vehicleMakeLogoUrl,
      packageName: PackageName(en: serviceNameEn, ar: serviceNameAr),
    );
  }

  // --- UI Compatibility Helpers ---
  String get title => CacheClient.getString(kLanguage) == kArabicLang
      ? (serviceNameAr ?? '')
      : (serviceNameEn ?? '');

  String get location => addressLabel ?? '';

  double get latitude => addressLat != null ? addressLat!.toDouble() : 0.0;
  double get longitude => addressLng != null ? addressLng!.toDouble() : 0.0;

  double get totalAmount => (totalAmountMinor ?? 0) / 100.0;

  bool get isUpcoming {
    if (status == null) return false;
    return status != BookingStatus.COMPLETED &&
        status != BookingStatus.CANCELLED;
  }

  String get formattedDateTime {
    if (scheduledAt == null) return '';
    try {
      final dateTime = DateTime.parse(scheduledAt!).toLocal();
      final timeStr = DateFormat.jm().format(dateTime);
      final dateStr = DateFormat.yMd().format(dateTime);
      return '$dateStr - $timeStr';
    } catch (_) {
      return scheduledAt!;
    }
  }
}
