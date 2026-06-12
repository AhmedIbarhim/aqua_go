import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/custom_loading_indicator.dart';
import 'theme_extension.dart';

OverlayEntry? _loadingOverlayEntry;
int _loadingCount = 0;

extension LoadingExtension on BuildContext {
  void showLoadingOverlay() {
    _loadingCount++;
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
    if (_loadingCount > 0) _loadingCount--;
    if (_loadingCount > 0) return;
    _loadingOverlayEntry?.remove();
    _loadingOverlayEntry = null;
  }
}
