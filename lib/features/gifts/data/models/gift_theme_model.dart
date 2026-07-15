import 'package:equatable/equatable.dart';

class GiftThemeModel extends Equatable {
  final String? id;
  final String? nameAr;
  final String? nameEn;
  final String? imageUrl;
  final int? displayOrder;
  final bool? active;

  const GiftThemeModel({
    this.id,
    this.nameAr,
    this.nameEn,
    this.imageUrl,
    this.displayOrder,
    this.active,
  });

  factory GiftThemeModel.fromJson(Map<String, dynamic> json) {
    return GiftThemeModel(
      id: json['id'] as String?,
      nameAr: json['nameAr'] as String?,
      nameEn: json['nameEn'] as String?,
      imageUrl: json['imageUrl'] as String?,
      displayOrder: json['displayOrder'] as int?,
      active: json['active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'active': active,
    };
  }

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    imageUrl,
    displayOrder,
    active,
  ];
}
