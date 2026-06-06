import 'package:equatable/equatable.dart';
import '../../../booking_and_subscriptions/shared/add_on_model.dart';
import '../../../../core/utils/app_assets.dart';

class ServiceModel extends Equatable {
  final String id;
  final String code;
  final ServiceName rawName;
  final ServiceDescription rawDescription;
  final bool active;
  final List<AddOnModel> addons;
  final int? priceMinor;
  final int? vatMinor;
  final String? currency;

  // Optionals for override values
  final String? priceOverride;
  final String? oldPriceOverride;
  final String? imageOverride;

  const ServiceModel({
    required this.id,
    required this.code,
    required this.rawName,
    required this.rawDescription,
    required this.active,
    required this.addons,
    this.priceMinor,
    this.vatMinor,
    this.currency,
    this.priceOverride,
    this.oldPriceOverride,
    this.imageOverride,
  });

  // Fallback getters for UI compatibility
  String get price => (priceMinor != null && priceMinor! > 0)
      ? (priceMinor! / 100).toStringAsFixed(2)
      : (priceOverride ?? '');
  String get oldPrice => oldPriceOverride ?? '';
  String get image => imageOverride ?? AppAssets.carDemo;

  double get basePriceDouble => priceDouble - vatDouble;
  double get vatDouble => (vatMinor ?? 0) / 100;
  double get priceDouble => (priceMinor ?? 0) / 100;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': rawName.toJson(),
      'description': rawDescription.toJson(),
      'active': active,
      'addons': addons.map((e) => e.toJson()).toList(),
      'priceMinor': priceMinor,
      'vatMinor': vatMinor,
      'currency': currency,
    };
  }

  @override
  List<Object?> get props => [
    id,
    code,
    rawName,
    rawDescription,
    active,
    addons,
    priceMinor,
    vatMinor,
    currency,
  ];
}

class ServiceName extends Equatable {
  final String nameAr;
  final String nameEn;

  const ServiceName({required this.nameAr, required this.nameEn});

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

  const ServiceDescription({required this.descAr, required this.descEn});

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
