import Flutter
import UIKit
import GoogleMaps
import QuickLook

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  /// Retained for the lifetime of the preview — QLPreviewController's data
  /// source is unowned, so a local would be gone before the first callback.
  private var previewItem: URL?

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
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "saveAndReveal":
        AppDelegate.saveAndReveal(call: call, result: result)
      case "openFile":
        self?.openFile(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Presents the file in QuickLook from the app's OWN root view controller.
  ///
  /// Deliberately not open_file: its iOS implementation resolves the presenting
  /// controller by scanning `connectedScenes` for whatever window happens to be
  /// `isKeyWindow` at that moment, so the preview can be pushed onto a
  /// controller that is not the Flutter one it was invoked from. Dismissing it
  /// then leaves the app on a black screen that only a relaunch clears. Here the
  /// presenting controller is the window's root, captured once and dismissed
  /// explicitly, so the preview can only ever return to the view it covered.
  private func openFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let path = args["path"] as? String
    else {
      result(FlutterError(code: "bad_args", message: "path missing", details: nil))
      return
    }
    let url = URL(fileURLWithPath: path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      result(FlutterError(code: "not_found", message: "no file at \(path)", details: nil))
      return
    }
    guard let presenter = window?.rootViewController else {
      result(FlutterError(code: "no_presenter", message: "no root view controller", details: nil))
      return
    }

    previewItem = url
    let preview = QLPreviewController()
    preview.dataSource = self
    preview.delegate = self
    // Present on whatever is already on top, so this composes with a Flutter
    // route that is itself presented modally instead of fighting it.
    (presenter.presentedViewController ?? presenter).present(preview, animated: true) {
      result(true)
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

// QuickLook needs a data source and gives us the dismissal callback that lets
// the preview item go; without releasing it the URL outlives every preview.
extension AppDelegate: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    previewItem == nil ? 0 : 1
  }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int)
    -> QLPreviewItem
  {
    previewItem! as QLPreviewItem
  }

  func previewControllerDidDismiss(_ controller: QLPreviewController) {
    previewItem = nil
  }
}
