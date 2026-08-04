import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCBWbLd9irc4PCEchf4WEMdIY8Io-PnScc")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerReceiptsChannel(with: engineBridge)
  }

  /// `aquago/receipts` — the app's first platform channel, mirrored on
  /// Android in MainActivity.kt. iOS has no public Downloads folder; the
  /// counterpart is the app's own Documents directory made visible in the
  /// Files app via `UIFileSharingEnabled` + `LSSupportsOpeningDocumentsInPlace`
  /// (Info.plist). The Dart caller (ReceiptSummaryView) already writes an
  /// identical app-private copy into the same directory via path_provider
  /// before calling this, so on iOS "reveal" is intentionally the same
  /// write repeated — there is no separate "visible" location the way
  /// Android's MediaStore Downloads collection is.
  private func registerReceiptsChannel(with engineBridge: FlutterImplicitEngineBridge) {
    let channel = FlutterMethodChannel(
      name: "aquago/receipts",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "saveAndReveal" else {
        result(FlutterMethodNotImplemented)
        return
      }
      AppDelegate.saveAndReveal(call: call, result: result)
    }
  }

  private static func saveAndReveal(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let typedBytes = args["bytes"] as? FlutterStandardTypedData,
      let filename = args["filename"] as? String
    else {
      result(FlutterError(code: "bad_args", message: "bytes/filename missing", details: nil))
      return
    }

    guard
      let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        .first
    else {
      result(
        FlutterError(
          code: "no_documents_dir", message: "Documents directory unavailable", details: nil))
      return
    }

    let fileUrl = documentsUrl.appendingPathComponent(filename)
    do {
      try typedBytes.data.write(to: fileUrl, options: .atomic)
      result(["ok": true])
    } catch {
      result(FlutterError(code: "write_failed", message: error.localizedDescription, details: nil))
    }
  }
}

