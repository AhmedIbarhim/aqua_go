import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/custom_loading_indicator.dart';
import 'theme_extension.dart';

OverlayEntry? _loadingOverlayEntry;

extension LoadingExtension on BuildContext {
  void showLoadingOverlay() {
    if (_loadingOverlayEntry != null) return;
    _loadingOverlayEntry = OverlayEntry(
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Material(
          color: context.colors.contentDisabled.withAlpha(10),
          child: const Center(child: CustomLoadingIndicator(size: 100)),
        ),
      ),
    );
    Overlay.of(this).insert(_loadingOverlayEntry!);
  }

  void hideLoadingOverlay() {
    _loadingOverlayEntry?.remove();
    _loadingOverlayEntry = null;
  }
}
