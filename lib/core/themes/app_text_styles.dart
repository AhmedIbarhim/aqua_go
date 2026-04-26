import 'package:flutter/material.dart';

abstract class AppTextStyles {
  // User provided examples
  static const TextStyle bold13 = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 13,
  );
  static const TextStyle bold23 = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 23,
  );
  static const TextStyle bold16 = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  // Extracted from Figma
  // XS (12px)
  static const TextStyle regular12 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
  );
  static const TextStyle medium12 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );

  // SM (14px)
  static const TextStyle regular14 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );
  static const TextStyle medium14 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );
  static const TextStyle leading6Regular14 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );
  static const TextStyle leading6Medium14 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  // Base (16px)
  static const TextStyle regular16 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
  );
  static const TextStyle medium16 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );
  static const TextStyle semiBold16 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  // LG (18px)
  static const TextStyle regular18 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 18,
  );
  static const TextStyle medium18 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18,
  );
  static const TextStyle semiBold18 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );
  static const TextStyle bold18 = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
  );

  // XL (20px)
  static const TextStyle regular20 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 20,
  );

  // 3XL (24px)
  static const TextStyle medium24 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 24,
  );
  static const TextStyle semiBold24 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 24,
  );

  // 7XL (32px)
  static const TextStyle regular32 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 32,
  );
  static const TextStyle semiBold32 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 32,
  );
}
