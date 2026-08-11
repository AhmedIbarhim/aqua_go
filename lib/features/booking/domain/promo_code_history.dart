import '../../../core/config/local_storage/shared_prefs.dart';
import '../../../core/constants.dart';
import '../../auth/data/models/user_model.dart';

class PromoCodeHistory {
  const PromoCodeHistory._();

  static const String storageKeyPrefix = 'promo_code_history';

  static const String legacyStorageKey = 'promo_code_history';

  static const int maxEntries = 5;

  static String _keyFor(String customerId) => '$storageKeyPrefix:$customerId';

  static String? _currentCustomerId() {
    final raw = CacheClient.getString(kUserData);
    if (raw.isEmpty) return null;
    final id = UserModel.fromEncodedJson(raw).id;
    return (id == null || id.isEmpty) ? null : id;
  }

  static List<String> recent() {
    final customerId = _currentCustomerId();
    if (customerId == null) return const <String>[];
    return CacheClient.getStringList(_keyFor(customerId));
  }

  static Future<void> remember(String code) async {
    final customerId = _currentCustomerId();
    if (customerId == null) return;
    final normalised = code.trim().toUpperCase();
    if (normalised.isEmpty) return;
    final updated = <String>[
      normalised,
      ...recent().where((entry) => entry != normalised),
    ];
    await CacheClient.setStringList(
      _keyFor(customerId),
      updated.take(maxEntries).toList(growable: false),
    );
  }

  static Future<void> forget() async {
    final customerId = _currentCustomerId();
    if (customerId != null) {
      await CacheClient.removeString(_keyFor(customerId));
    }
    await forgetLegacyDeviceStore();
  }

  static Future<void> forgetLegacyDeviceStore() async {
    await CacheClient.removeString(legacyStorageKey);
  }
}
