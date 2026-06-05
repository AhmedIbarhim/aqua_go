import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isTablet => screenWidth >= 600;
  bool get isMobile => screenWidth < 600;

  // Global responsive scaling helpers (base canvas: 414x896)
  double sw(double width) => (width / 414) * screenWidth;
  double sh(double height) => (height / 896) * screenHeight;
}
