import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String id;
  final String code;
  final ServiceName rawName;
  final ServiceDescription rawDescription;
  final bool active;
  final List<dynamic> addons;

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
    this.priceOverride,
    this.oldPriceOverride,
    this.imageOverride,
  });

  // Fallback getters for UI compatibility
  String get price => priceOverride ?? '90.00';
  String get oldPrice => oldPriceOverride ?? '100.00';
  String get image => imageOverride ?? 'assets/images/car_demo.png';

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      rawName: ServiceName.fromJson(json['name']),
      rawDescription: ServiceDescription.fromJson(json['description']),
      active: json['active'] as bool? ?? true,
      addons: json['addons'] as List<dynamic>? ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': rawName.toJson(),
      'description': rawDescription.toJson(),
      'active': active,
      'addons': addons,
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
