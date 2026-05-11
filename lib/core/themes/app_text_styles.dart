import 'dart:ui';
import 'package:flutter/material.dart';

class AppTextStyles {
  static double get _scaleFactor {
    final dispatcher = PlatformDispatcher.instance;
    final view = dispatcher.implicitView;
    if (view == null) return 1.0;
    double width = view.physicalSize.width / view.devicePixelRatio;
    if (width == 0) return 1.0;

    // Base width 414 (iPhone 11/12/13/14)
    if (width < 600) return width / 414;
    // For tablets, don't scale too much
    if (width < 900) return width / 750;
    return 1.2; // Max scale for large screens
  }

  static double _sp(double fontSize) =>
      (fontSize * _scaleFactor).clamp(fontSize * 0.8, fontSize * 1.4);

  // User provided examples
  static TextStyle get bold13 => TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: _sp(13),
      );
  static TextStyle get bold23 => TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: _sp(23),
      );
  static TextStyle get bold16 => TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: _sp(16),
      );

  static TextStyle get regular10 => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: _sp(10),
      );
  static TextStyle get medium10 => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: _sp(10),
      );
  static TextStyle get semiBold10 => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: _sp(10),
      );
  static TextStyle get bold10 => TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: _sp(10),
      );

  static TextStyle get regular11 => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: _sp(11),
      );
  static TextStyle get medium11 => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: _sp(11),
      );
  static TextStyle get semiBold11 => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: _sp(11),
      );
  static TextStyle get bold11 => TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: _sp(11),
      );

  // Extracted from Figma
  // XS (12px)
  static TextStyle get regular12 => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: _sp(12),
      );
  static TextStyle get medium12 => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: _sp(12),
      );

  // SM (14px)
  static TextStyle get regular14 => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: _sp(14),
      );
  static TextStyle get medium14 => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: _sp(14),
      );
  static TextStyle get leading6Regular14 => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: _sp(14),
      );
  static TextStyle get leading6Medium14 => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: _sp(14),
      );

  // Base (16px)
  static TextStyle get regular16 => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: _sp(16),
      );
  static TextStyle get medium16 => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: _sp(16),
      );
  static TextStyle get semiBold16 => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: _sp(16),
      );

  // LG (18px)
  static TextStyle get regular18 => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: _sp(18),
      );
  static TextStyle get medium18 => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: _sp(18),
      );
  static TextStyle get semiBold18 => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: _sp(18),
      );
  static TextStyle get bold18 => TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: _sp(18),
      );

  // XL (20px)
  static TextStyle get regular20 => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: _sp(20),
      );

  // 3XL (24px)
  static TextStyle get medium24 => TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: _sp(24),
      );
  static TextStyle get semiBold24 => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: _sp(24),
      );

  // 7XL (32px)
  static TextStyle get regular32 => TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: _sp(32),
      );
  static TextStyle get semiBold32 => TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: _sp(32),
      );
}
