import 'package:aqua_go/core/config/di/service_locator.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/payment/moyasar_config.dart';
import 'package:aqua_go/core/config/payment/payment_sdk_config_remote_data_source.dart';
import 'package:flutter/foundation.dart';

/// Lazy, idempotent loader for the Moyasar SDK configuration.
///
/// Call [ensureLoaded] at the payment launch points (before showing
/// [MoyasarPaymentView]). The first call hits the server; subsequent calls
/// return immediately. Concurrent first calls share the same in-flight Future.
///
/// On failure the error is logged and swallowed so the existing
/// [MoyasarConfig.isConfigured] guard in [MoyasarPaymentView] surfaces the
/// "payment not configured" screen rather than crashing the app.
class PaymentSdkConfigService {
  PaymentSdkConfigService._();

  static final PaymentSdkConfigService instance = PaymentSdkConfigService._();

  bool _loaded = false;
  Future<void>? _inFlight;

  /// Ensures the SDK config has been fetched from the server.
  ///
  /// Idempotent: safe to call from multiple launch points.
  /// The user is authenticated before any payment surface is shown, so the
  /// JWT is available when this runs.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _inFlight ??= _fetch().whenComplete(() {
      _inFlight = null;
    });
    await _inFlight;
  }

  Future<void> _fetch() async {
    try {
      final dataSource = PaymentSdkConfigRemoteDataSource(
        locator<APIClient>(),
      );
      final result = await dataSource.getSdkConfig();
      result.fold(
        (failure) {
          debugPrint(
            '[PaymentSdkConfigService] fetch failed: ${failure.type} — '
            '${failure.message}',
          );
          // Leave _loaded = false so a later call can retry.
        },
        (config) {
          MoyasarConfig.applyServerConfig(
            publishableApiKey: config.publishableApiKey,
            applePayMerchantId: config.applePayMerchantId,
            applePayLabel: config.applePayLabel,
            currency: config.currency,
          );
          _loaded = true;
        },
      );
    } catch (e) {
      debugPrint('[PaymentSdkConfigService] unexpected error: $e');
      // Leave _loaded = false so a later call can retry.
    }
  }
}
