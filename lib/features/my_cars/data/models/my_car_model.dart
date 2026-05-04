import '../../../../core/helpers/car_color_helper.dart';

class MyCarModel {
  final String name;
  final String model;
  final String year;
  final String image;
  final String boardNumber;
  final String typeImage;
  final int colorCode;

  MyCarModel({
    required this.name,
    required this.model,
    required this.year,
    required this.image,
    required this.boardNumber,
    required this.typeImage,
    this.colorCode = 0xFFFFFF,
  });

  String get colorName => getLocalizedColorName(colorCode);
}
