import '../../../core/config/local_storage/shared_prefs.dart';

/// The codes this device has successfully applied, most recent first — the
/// source for UCC16's "autocomplete of previously used codes".
///
/// Device-local by deliberate choice. There is no customer-facing endpoint that
/// lists the codes a customer has used, and adding one would publish which
/// codes a given customer holds; the codes are already on this device because
/// the customer typed them here. Only codes the BACKEND accepted are recorded,
/// so a suggestion is never a code that has never worked.
class PromoCodeHistory {
  const PromoCodeHistory._();

  static const String storageKey = 'promo_code_history';

  /// Enough to cover the codes a customer actually reuses without turning the
  /// dialog into a list they have to read.
  static const int maxEntries = 5;

  /// Previously applied codes, most recent first.
  static List<String> recent() => CacheClient.getStringList(storageKey);

  /// Records [code] as the most recently used, de-duplicating it out of its old
  /// position so re-using an old code moves it to the front rather than
  /// repeating it. Stored upper case, matching how the server normalises it, so
  /// `welcome20` and `WELCOME20` are never suggested as two different codes.
  static Future<void> remember(String code) async {
    final normalised = code.trim().toUpperCase();
    if (normalised.isEmpty) return;
    final updated = <String>[
      normalised,
      ...recent().where((entry) => entry != normalised),
    ];
    await CacheClient.setStringList(
      storageKey,
      updated.take(maxEntries).toList(growable: false),
    );
  }
}
