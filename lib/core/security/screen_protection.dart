import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

/// PH1-022: blocks screenshots / screen-recording (Android FLAG_SECURE + iOS
/// screenshot block) and hides screen content in the iOS app-switcher snapshot
/// with a solid cover, for sensitive screens (OTP, payment, profile).
///
/// The concrete platform calls sit behind [ScreenProtection] so screens depend
/// on a mockable seam (widget tests never touch the platform channel).
abstract class ScreenProtection {
  /// Raw platform ON (FLAG_SECURE / iOS block + snapshot cover). Invoked only
  /// via [ScreenProtectionScope], which reference-counts live scopes so this
  /// fires exactly once for a whole stack of protected screens.
  Future<void> enable();

  /// Raw platform OFF. Invoked only when the last protected scope is disposed.
  Future<void> disable();

  static ScreenProtection instance = const _ScreenProtectorImpl();

  @visibleForTesting
  static void setInstanceForTesting(ScreenProtection value) => instance = value;

  @visibleForTesting
  static void resetInstance() {
    instance = const _ScreenProtectorImpl();
    _ScreenProtectionScopeState._activeScopes = 0;
  }
}

class _ScreenProtectorImpl implements ScreenProtection {
  const _ScreenProtectorImpl();

  @override
  Future<void> enable() async {
    await ScreenProtector.protectDataLeakageOn(); // Android FLAG_SECURE
    await ScreenProtector.preventScreenshotOn(); // iOS screenshot/record block
    // iOS app-switcher snapshot cover — a solid island so no content leaks to
    // the recents thumbnail. Not a theme change: the visible screen is untouched.
    await ScreenProtector.protectDataLeakageWithColor(Colors.white);
  }

  @override
  Future<void> disable() async {
    await ScreenProtector.protectDataLeakageOff();
    await ScreenProtector.preventScreenshotOff();
    await ScreenProtector.protectDataLeakageWithColorOff();
  }
}

/// Wrap a sensitive screen's build output in this scope: protection turns on
/// when the screen mounts and off when it is disposed. Uniform across Stateless
/// and Stateful screens without converting them.
class ScreenProtectionScope extends StatefulWidget {
  const ScreenProtectionScope({super.key, required this.child});

  final Widget child;

  @override
  State<ScreenProtectionScope> createState() => _ScreenProtectionScopeState();
}

class _ScreenProtectionScopeState extends State<ScreenProtectionScope> {
  // One global platform flag guards every protected screen, so reference-count
  // the live scopes: turn the platform ON when the first scope mounts and OFF
  // only when the last one is disposed. Without this, popping a stacked
  // protected child (e.g. profile -> edit profile -> back) would disable
  // protection while the protected parent beneath it is still on screen,
  // leaving a PII screen screenshot-able (PH1-022 review blocker).
  static int _activeScopes = 0;

  @override
  void initState() {
    super.initState();
    if (_activeScopes == 0) {
      ScreenProtection.instance.enable();
    }
    _activeScopes++;
  }

  @override
  void dispose() {
    _activeScopes--;
    if (_activeScopes <= 0) {
      _activeScopes = 0;
      ScreenProtection.instance.disable();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
