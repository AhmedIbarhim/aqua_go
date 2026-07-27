import '../../../core/config/local_storage/shared_prefs.dart';
import '../../../core/constants.dart';
import '../../auth/data/models/user_model.dart';

/// The codes this device has successfully applied, most recent first — the
/// source for UCC16's "autocomplete of previously used codes".
///
/// Device-local by deliberate choice. There is no customer-facing endpoint that
/// lists the codes a customer has used, and adding one would publish which
/// codes a given customer holds; the codes are already on this device because
/// the customer typed them here. Only codes the BACKEND accepted are recorded,
/// so a suggestion is never a code that has never worked.
///
/// **Scoped per customer, and erased on sign-out.** The store used to sit under
/// one unscoped key, which meant the reasoning above stopped one step short: the
/// codes never left the device, but the NEXT person to sign in on the same
/// handset was offered them, and sharing a phone is ordinary here. Two things
/// close it — the key carries the customer's local id, so a suggestion can only
/// come from the account that earned it, and [forget] runs inside the same
/// targeted teardown as the session tokens, so a deleted account leaves nothing
/// behind (PDPL erasure reaches the handset, not only the server).
class PromoCodeHistory {
  const PromoCodeHistory._();

  /// Key stem. The customer's local id is appended — see [_keyFor].
  static const String storageKeyPrefix = 'promo_code_history';

  /// The pre-scoping key. Never read any more; [forget] removes it so the codes
  /// an earlier customer left on a shared device do not sit there indefinitely.
  static const String legacyStorageKey = 'promo_code_history';

  /// Enough to cover the codes a customer actually reuses without turning the
  /// dialog into a list they have to read.
  static const int maxEntries = 5;

  static String _keyFor(String customerId) => '$storageKeyPrefix:$customerId';

  /// The signed-in customer's local id, read from the SAME cached user record
  /// the session teardown removes.
  ///
  /// Read here rather than injected so the call sites stay argument-free and
  /// free of a service-locator lookup, and so [forget] cannot be handed an id
  /// that disagrees with the one [remember] wrote under. Null for a guest or a
  /// signed-out viewer.
  static String? _currentCustomerId() {
    final raw = CacheClient.getString(kUserData);
    if (raw.isEmpty) return null;
    final id = UserModel.fromEncodedJson(raw).id;
    return (id == null || id.isEmpty) ? null : id;
  }

  /// The signed-in customer's previously applied codes, most recent first.
  ///
  /// Empty when nobody is signed in — a guest has no history of their own and
  /// must not be handed somebody else's.
  static List<String> recent() {
    final customerId = _currentCustomerId();
    if (customerId == null) return const <String>[];
    return CacheClient.getStringList(_keyFor(customerId));
  }

  /// Records [code] as the signed-in customer's most recently used, de-duplicating
  /// it out of its old position so re-using an old code moves it to the front
  /// rather than repeating it. Stored upper case, matching how the server
  /// normalises it, so `welcome20` and `WELCOME20` are never two entries.
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

  /// Erases the signed-in customer's history, plus the unscoped store older
  /// builds wrote.
  ///
  /// Called from every session teardown — sign-out, the forced purge on a dead
  /// refresh token, and account deletion — so a handset holds no record of a
  /// customer who is no longer signed in on it. **Call it BEFORE the cached
  /// user record is removed**: the key is derived from that record, and after
  /// it is gone there is nothing left to derive.
  static Future<void> forget() async {
    final customerId = _currentCustomerId();
    if (customerId != null) {
      await CacheClient.removeString(_keyFor(customerId));
    }
    await CacheClient.removeString(legacyStorageKey);
  }
}
