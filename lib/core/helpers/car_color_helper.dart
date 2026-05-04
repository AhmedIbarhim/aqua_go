import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../generated/locale_keys.g.dart';

String getLocalizedColorName(int colorCode) {
  switch (colorCode) {
    case 0xFFa97142:
      return LocaleKeys.my_cars_colors_bronze.tr();
    case 0xFFf97316:
      return LocaleKeys.my_cars_colors_orange.tr();
    case 0xFF4b5563:
      return LocaleKeys.my_cars_colors_charcoal.tr();
    case 0xFF9ca3af:
      return LocaleKeys.my_cars_colors_gray.tr();
    case 0xFFc0c0c0:
      return LocaleKeys.my_cars_colors_silver.tr();
    case 0xFFf5f5f0:
      return LocaleKeys.my_cars_colors_pearl_white.tr();
    case 0xFFffffff:
      return LocaleKeys.my_cars_colors_white.tr();
    case 0xFF0e0e0e:
      return LocaleKeys.my_cars_colors_black.tr();
    case 0xFF7c4a2d:
      return LocaleKeys.my_cars_colors_brown.tr();
    case 0xFFfacc15:
      return LocaleKeys.my_cars_colors_yellow.tr();
    case 0xFF15803d:
      return LocaleKeys.my_cars_colors_green.tr();
    case 0xFF7f1d1d:
      return LocaleKeys.my_cars_colors_burgundy.tr();
    case 0xFFdc2626:
      return LocaleKeys.my_cars_colors_red.tr();
    case 0xFF1e3a8a:
      return LocaleKeys.my_cars_colors_dark_blue.tr();
    case 0xFF2563eb:
      return LocaleKeys.my_cars_colors_blue.tr();
    case 0xFF7dd3fc:
      return LocaleKeys.my_cars_colors_light_blue.tr();
    default:
      return LocaleKeys.my_cars_custom_color.tr();
  }
}

List<Color> carColors = [
  Color(0xFFa97142), // Bronze
  Color(0xFFf97316), // Orange
  Color(0xFF4b5563), // Charcoal
  Color(0xFF9ca3af), // Gray
  Color(0xFFc0c0c0), // Silver
  Color(0xFFf5f5f0), // Pearl White
  Color(0xFFffffff), // White
  Color(0xFF0e0e0e), // Black
  Color(0xFF7c4a2d), // Brown
  Color(0xFFfacc15), // Yellow
  Color(0xFF15803d), // Green
  Color(0xFF7f1d1d), // Burgundy
  Color(0xFFdc2626), // Red
  Color(0xFF1e3a8a), // Dark Blue
  Color(0xFF2563eb), // Blue
  Color(0xFF7dd3fc), // Light Blue
];
