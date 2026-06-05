import 'package:flutter/material.dart';

extension BottomSheetExtension on BuildContext {
  void showCustomBottomSheet({required Widget child}) {
    showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => child,
    );
  }
}
