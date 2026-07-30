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
    final entry = _loadingOverlayEntry;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && entry == _loadingOverlayEntry && entry != null) {
        Overlay.of(this).insert(entry);
      }
    });
  }

  void hideLoadingOverlay() {
    if (_loadingCount > 0) _loadingCount--;
    if (_loadingCount > 0) return;
    final entry = _loadingOverlayEntry;
    _loadingOverlayEntry = null;
    if (entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // The insert is itself deferred to a post-frame callback, and it
        // skips itself once `_loadingOverlayEntry` has moved on. A show+hide
        // pair inside one frame gap therefore leaves this entry never
        // inserted, and `remove()` asserts on an entry that has no overlay.
        // Latent in production only because a real request spans a frame.
        if (entry.mounted) entry.remove();
      });
    }
  }
}
