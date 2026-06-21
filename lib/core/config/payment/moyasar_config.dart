/// Moyasar client configuration.
///
/// Secrets are NEVER committed. The publishable key + Apple Pay merchant-id
/// are injected at build time via `--dart-define`:
///
///   flutter run \
///     --dart-define=MOYASAR_PUBLISHABLE_KEY=pk_test_xxx \
///     --dart-define=APPLE_PAY_MERCHANT_ID=merchant.sa.aquago
///
/// The publishable key is safe to ship in the binary (it can only create
/// payments, never read/refund); the secret key lives server-side only.
abstract class MoyasarConfig {
  /// Moyasar publishable key (`pk_test_…` / `pk_live_…`). Empty when not
  /// provided at build time — the payment screen surfaces a config error
  /// rather than calling the SDK with a blank key.
  static const String publishableApiKey = String.fromEnvironment(
    'MOYASAR_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Apple Pay merchant identifier (iOS only). Must match the merchant-id in
  /// the Apple Pay entitlement / the value registered in the Moyasar
  /// dashboard.
  static const String applePayMerchantId = String.fromEnvironment(
    'APPLE_PAY_MERCHANT_ID',
    defaultValue: '',
  );

  /// Store label shown on the Apple Pay sheet.
  static const String applePayLabel = 'Aqua Go';

  /// ISO 4217 currency — KSA only.
  static const String currency = 'SAR';

  static bool get isConfigured => publishableApiKey.isNotEmpty;
}
