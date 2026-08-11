import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

abstract class ScreenProtection {
  Future<void> enable();

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

    await ScreenProtector.protectDataLeakageWithColor(Colors.white);
  }

  @override
  Future<void> disable() async {
    await ScreenProtector.protectDataLeakageOff();
    await ScreenProtector.preventScreenshotOff();
    await ScreenProtector.protectDataLeakageWithColorOff();
  }
}

class ScreenProtectionScope extends StatefulWidget {
  const ScreenProtectionScope({super.key, required this.child});

  final Widget child;

  @override
  State<ScreenProtectionScope> createState() => _ScreenProtectionScopeState();
}

class _ScreenProtectionScopeState extends State<ScreenProtectionScope> {
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
