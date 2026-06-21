/// Moyasar client configuration.
///
/// The publishable key and Apple Pay config are loaded at runtime from the
/// server (GET /api/customer/payments/sdk-config via [PaymentSdkConfigService])
/// so they do not need to be compiled into the binary via --dart-define.
///
/// For local development / CI builds that still use --dart-define, those
/// compile-time values act as a FALLBACK when the server value is absent or
/// the fetch has not completed yet.
///
///   flutter run \
///     --dart-define=MOYASAR_PUBLISHABLE_KEY=pk_test_xxx \
///     --dart-define=APPLE_PAY_MERCHANT_ID=merchant.sa.aquago
abstract class MoyasarConfig {
  // ---------------------------------------------------------------------------
  // Build-time fallbacks (--dart-define). These are used when the server has
  // not yet provided a runtime value.
  // ---------------------------------------------------------------------------

  static const String _envPublishableApiKey = String.fromEnvironment(
    'MOYASAR_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const String _envApplePayMerchantId = String.fromEnvironment(
    'APPLE_PAY_MERCHANT_ID',
    defaultValue: '',
  );

  // ---------------------------------------------------------------------------
  // Runtime values — populated by [applyServerConfig].
  // ---------------------------------------------------------------------------

  static String? _runtimePublishableApiKey;
  static String? _runtimeApplePayMerchantId;
  static String? _runtimeApplePayLabel;
  static String? _runtimeCurrency;

  // ---------------------------------------------------------------------------
  // Effective getters — prefer runtime, fall back to --dart-define / literal.
  // ---------------------------------------------------------------------------

  /// Moyasar publishable key (`pk_test_…` / `pk_live_…`).
  /// Empty when neither the server nor --dart-define provided a value — the
  /// payment screen surfaces a config error rather than calling the SDK with
  /// a blank key.
  static String get publishableApiKey =>
      (_runtimePublishableApiKey?.isNotEmpty == true)
          ? _runtimePublishableApiKey!
          : _envPublishableApiKey;

  /// Apple Pay merchant identifier (iOS only).
  static String get applePayMerchantId =>
      (_runtimeApplePayMerchantId?.isNotEmpty == true)
          ? _runtimeApplePayMerchantId!
          : _envApplePayMerchantId;

  /// Store label shown on the Apple Pay sheet.
  static String get applePayLabel =>
      (_runtimeApplePayLabel?.isNotEmpty == true)
          ? _runtimeApplePayLabel!
          : 'Aqua Go';

  /// ISO 4217 currency — KSA only.
  static String get currency =>
      (_runtimeCurrency?.isNotEmpty == true) ? _runtimeCurrency! : 'SAR';

  /// True when a non-empty publishable key is available (from server or
  /// --dart-define). Used by [MoyasarPaymentView] to guard against an
  /// un-configured state.
  static bool get isConfigured => publishableApiKey.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Called by [PaymentSdkConfigService] after a successful server fetch.
  // ---------------------------------------------------------------------------

  /// Stores the server-supplied config. Must be called before the payment
  /// view is shown. Safe to call more than once (idempotent for the same
  /// values). Non-empty values overwrite the current runtime state; empty /
  /// null values are ignored so --dart-define fallbacks are preserved.
  static void applyServerConfig({
    required String publishableApiKey,
    String? applePayMerchantId,
    String? applePayLabel,
    String? currency,
  }) {
    if (publishableApiKey.isNotEmpty) {
      _runtimePublishableApiKey = publishableApiKey;
    }
    if (applePayMerchantId != null && applePayMerchantId.isNotEmpty) {
      _runtimeApplePayMerchantId = applePayMerchantId;
    }
    if (applePayLabel != null && applePayLabel.isNotEmpty) {
      _runtimeApplePayLabel = applePayLabel;
    }
    if (currency != null && currency.isNotEmpty) {
      _runtimeCurrency = currency;
    }
  }
}
