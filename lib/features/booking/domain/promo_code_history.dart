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
/// **Scoped per customer, and it SURVIVES a sign-out.** The store used to sit
/// under one unscoped key, which meant the reasoning above stopped one step
/// short: the codes never left the device, but the NEXT person to sign in on the
/// same handset was offered them, and sharing a phone is ordinary here. The key
/// now carries the customer's local id, so a suggestion can only ever come from
/// the account that earned it — which is what makes it safe to KEEP the entries
/// across a logout. Clearing them there instead would have closed the same hole
/// by deleting the feature: UCC16's "autocomplete of previously used codes"
/// would last exactly one session, and a customer who signs back in on their own
/// phone would be offered nothing.
///
/// [forget] therefore belongs to account DELETION only, where erasure is the
/// point (PDPL reaches the handset, not only the server). Ordinary sign-outs
/// call [forgetLegacyDeviceStore], which clears the pre-scoping shared store and
/// nothing else.
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
  /// **Account deletion only.** A sign-out is not an erasure — the codes are
  /// keyed to the account that earned them, so nobody else can be offered them,
  /// and wiping them would reduce UCC16's autocomplete to a single session. Use
  /// [forgetLegacyDeviceStore] on the ordinary teardown paths.
  ///
  /// **Call it BEFORE the cached user record is removed**: the key is derived
  /// from that record, and after it is gone there is nothing left to derive.
  static Future<void> forget() async {
    final customerId = _currentCustomerId();
    if (customerId != null) {
      await CacheClient.removeString(_keyFor(customerId));
    }
    await forgetLegacyDeviceStore();
  }

  /// Removes ONLY the pre-scoping unscoped store.
  ///
  /// Nothing writes that key any more, but a handset upgraded from an older
  /// build still carries whatever the previous signed-in customer left there.
  /// Clearing it on every session teardown gets it off the device without
  /// touching the current customer's own, correctly-scoped history.
  static Future<void> forgetLegacyDeviceStore() async {
    await CacheClient.removeString(legacyStorageKey);
  }
}
