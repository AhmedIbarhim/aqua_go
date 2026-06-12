import 'package:equatable/equatable.dart';
import 'add_on_model.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../my_bookings/data/models/booking_response_model/breakdown.dart';

class ServiceModel extends Equatable {
  final String? id;
  final String? code;
  final String? refNumber;
  final ServiceName? rawName;
  final ServiceDescription? rawDescription;
  final bool? active;
  final List<AddOnModel> addons;
  final int? priceMinor;
  final int? vatMinor;
  final String? currency;
  final Breakdown? breakdown;

  // Optionals for override values
  final String? priceOverride;
  final String? oldPriceOverride;
  final String? imageOverride;

  const ServiceModel({
    this.id,
    this.code,
    this.refNumber,
    this.rawName,
    this.rawDescription,
    this.active,
    this.addons = const [],
    this.priceMinor,
    this.vatMinor,
    this.currency,
    this.breakdown,
    this.priceOverride,
    this.oldPriceOverride,
    this.imageOverride,
  });

  // Fallback getters for UI compatibility
  String get price => breakdown != null
      ? breakdown!.gross.toStringAsFixed(2)
      : ((priceMinor != null && priceMinor! > 0)
            ? (priceMinor! / 100).toStringAsFixed(2)
            : (priceOverride ?? ''));
  String get oldPrice => oldPriceOverride ?? '';
  String get image => imageOverride ?? AppAssets.carDemo;

  double get basePriceDouble =>
      breakdown != null ? breakdown!.net : (priceDouble - vatDouble);
  double get vatDouble =>
      breakdown != null ? breakdown!.vat : ((vatMinor ?? 0) / 100);
  double get priceDouble =>
      breakdown != null ? breakdown!.gross : ((priceMinor ?? 0) / 100);

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      refNumber: json['referenceNumber'] as String? ?? '',
      rawName: ServiceName.fromJson(json['name']),
      rawDescription: ServiceDescription.fromJson(json['description']),
      active: json['active'] as bool? ?? true,
      addons:
          (json['addons'] as List<dynamic>?)
              ?.map((e) => AddOnModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      priceMinor: (json['priceMinor'] as num?)?.toInt(),
      vatMinor: (json['vatMinor'] as num?)?.toInt(),
      currency: json['currency'] as String?,
      breakdown: json['breakdown'] != null
          ? Breakdown.fromJson(json['breakdown'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    refNumber,
    rawName,
    rawDescription,
    active,
    addons,
    priceMinor,
    vatMinor,
    currency,
    breakdown,
  ];
}

class ServiceName extends Equatable {
  final String nameAr;
  final String nameEn;

  const ServiceName({this.nameAr = '', this.nameEn = ''});

  factory ServiceName.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ServiceName(
        nameAr: json['ar_SA']?.toString() ?? '',
        nameEn: json['en']?.toString() ?? '',
      );
    }
    return const ServiceName(nameAr: '', nameEn: '');
  }

  Map<String, dynamic> toJson() {
    return {'ar_SA': nameAr, 'en': nameEn};
  }

  @override
  List<Object?> get props => [nameAr, nameEn];
}

class ServiceDescription extends Equatable {
  final String descAr;
  final String descEn;

  const ServiceDescription({this.descAr = '', this.descEn = ''});

  factory ServiceDescription.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ServiceDescription(
        descAr: json['ar_SA']?.toString() ?? '',
        descEn: json['en']?.toString() ?? '',
      );
    }
    return const ServiceDescription(descAr: '', descEn: '');
  }

  Map<String, dynamic> toJson() {
    return {'ar_SA': descAr, 'en': descEn};
  }

  @override
  List<Object?> get props => [descAr, descEn];
}
