import 'dart:io' show Platform;

import 'package:flutter/services.dart';

sealed class ReceiptRevealOutcome {
  const ReceiptRevealOutcome();
}

final class ReceiptRevealOk extends ReceiptRevealOutcome {
  const ReceiptRevealOk();
}

final class ReceiptRevealPermissionDenied extends ReceiptRevealOutcome {
  const ReceiptRevealPermissionDenied();
}

final class ReceiptRevealFailed extends ReceiptRevealOutcome {
  const ReceiptRevealFailed();
}

class ReceiptFilesChannel {
  ReceiptFilesChannel._();

  static const MethodChannel _channel = MethodChannel('aquago/receipts');

  static Future<ReceiptRevealOutcome> saveAndReveal({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>(
        'saveAndReveal',
        {'bytes': bytes, 'filename': filename, 'mimeType': mimeType},
      );
      if (raw?['ok'] == true) return const ReceiptRevealOk();
      if (raw?['reason'] == 'permission_denied') {
        return const ReceiptRevealPermissionDenied();
      }
      return const ReceiptRevealFailed();
    } on PlatformException {
      return const ReceiptRevealFailed();
    } on MissingPluginException {
      return const ReceiptRevealFailed();
    }
  }

  static Future<bool> openFile(String path) async {
    if (!Platform.isIOS) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('openFile', {'path': path});
      return ok ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
