import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// The outcome of the native "reveal" step — writing a second, user-visible
/// copy of a downloaded file into the platform's Downloads surface (Android)
/// or the app's Documents directory (iOS, exposed via `UIFileSharingEnabled`
/// in the Files app). This is deliberately separate from being able to OPEN
/// the file: callers write their own app-private copy first (see
/// `ReceiptSummaryView`) and open THAT regardless of what this returns —
/// "reveal" is best-effort visibility, not a precondition for opening.
sealed class ReceiptRevealOutcome {
  const ReceiptRevealOutcome();
}

/// The visible copy was written.
final class ReceiptRevealOk extends ReceiptRevealOutcome {
  const ReceiptRevealOk();
}

/// Android API 24-28 only: the legacy `WRITE_EXTERNAL_STORAGE` runtime
/// permission was declined, so no copy could be written to the public
/// Downloads directory. A routine, localisable outcome — not an exception.
/// (API 29+ needs no permission for the MediaStore Downloads insert.)
final class ReceiptRevealPermissionDenied extends ReceiptRevealOutcome {
  const ReceiptRevealPermissionDenied();
}

/// Anything else that stopped the visible copy from being written (a native
/// I/O error, an unexpected result shape). Distinct from
/// [ReceiptRevealPermissionDenied] so callers don't mis-localise a real
/// failure as a permission prompt.
final class ReceiptRevealFailed extends ReceiptRevealOutcome {
  const ReceiptRevealFailed();
}

/// The app's first platform channel — `aquago/receipts`. There is no
/// maintained Flutter plugin for "insert a file into the MediaStore
/// Downloads collection" / "make a file visible in the iOS Files app" that
/// meets the bar the owner set (see the brief this shipped against: no
/// Android-only, unmaintained, or `requestLegacyExternalStorage`-reliant
/// storage packages), so this is hand-written native code on both sides.
class ReceiptFilesChannel {
  ReceiptFilesChannel._();

  static const MethodChannel _channel = MethodChannel('aquago/receipts');

  /// Writes [bytes] into the platform's user-visible file surface under
  /// [filename] with content type [mimeType]. Never throws for the one
  /// anticipated recoverable failure (legacy storage permission denial) —
  /// see [ReceiptRevealOutcome]. Any other native exception is caught here
  /// and reported as [ReceiptRevealFailed] rather than propagated, because a
  /// failed "reveal" must not read to the caller as a failed download.
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

  /// Opens [path] in the OS viewer.
  ///
  /// iOS ONLY — returns false on every other platform so the caller falls back
  /// to open_file. open_file's iOS side picks its presenting controller by
  /// scanning for the current key window, which can leave the app on a black
  /// screen once the preview is dismissed; the native side here presents
  /// QuickLook from our own root view controller instead. Android keeps
  /// open_file, whose implementation is an ACTION_VIEW intent and shares none
  /// of that machinery.
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
