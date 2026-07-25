/// Single-shot, in-memory handoff for a promo code the customer picked from an
/// offer ("Use this code"). The booking summary consumes it once, at the start
/// of the next quote, and the read clears it so a code never silently
/// re-applies to a later, unrelated booking.
///
/// Deliberately NOT persisted: an offer can stop being eligible between app
/// launches, and a stale code would produce a confusing 422 at quote time.
class PendingPromoCode {
  PendingPromoCode._();

  static final PendingPromoCode instance = PendingPromoCode._();

  String? _code;

  /// Stores [code] for the next quote, replacing any previously stored code.
  void set(String code) {
    final trimmed = code.trim();
    _code = trimmed.isEmpty ? null : trimmed;
  }

  /// Returns the stored code and clears it. Returns null when nothing is stored.
  String? take() {
    final value = _code;
    _code = null;
    return value;
  }

  /// Drops any stored code without consuming it (used when a flow is abandoned).
  void clear() => _code = null;
}
