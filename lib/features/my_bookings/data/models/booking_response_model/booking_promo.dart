import '../../../../../core/utils/saudi_wire_format.dart';

/// The promo code applied to a booking, with the offer it came through.
/// Mirrors the backend record `BookingPromo` on `BookingResponse.promo`.
///
/// UCC16 step 4 — "discount applied to total; breakdown shown" — does not stop
/// at the booking-review screen: the customer's own booking detail has to be
/// able to say which code applied and what it saved. Admin got this surface
/// first; this is the customer half.
class BookingPromo {
  /// The redeemed code, always upper case on the wire.
  final String? code;

  /// Discount granted on this booking, in halala. ALREADY netted off
  /// `totalAmountMinor` — it is a statement of what was saved, never a figure to
  /// subtract again.
  final int discountMinor;

  /// The merchandising offer the customer came through, or null when they typed
  /// the code in manually. Not derivable from the code: two live offers may link
  /// the same one (UCA22 A6).
  final String? offerId;

  /// When the code was redeemed, in the Riyadh frame.
  final DateTime? redeemedAt;

  /// When the promo slot was given back — the booking was cancelled — or null
  /// while the redemption still stands. A released redemption no longer counts
  /// against the campaign, but the discount it granted still shaped what this
  /// booking was charged, so the row stays on the detail either way.
  final DateTime? releasedAt;

  const BookingPromo({
    this.code,
    this.discountMinor = 0,
    this.offerId,
    this.redeemedAt,
    this.releasedAt,
  });

  /// Read-reconstruction path: every field degrades to a safe default so a
  /// partial or legacy payload yields a usable model rather than a TypeError
  /// that kills the booking detail screen.
  factory BookingPromo.fromJson(Map<String, dynamic> json) => BookingPromo(
    code: json['code'] as String?,
    discountMinor: (json['discountMinor'] as num?)?.toInt() ?? 0,
    offerId: json['offerId'] as String?,
    redeemedAt: tryParseWireDateTime(json['redeemedAt'] as String?),
    releasedAt: tryParseWireDateTime(json['releasedAt'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'discountMinor': discountMinor,
    'offerId': offerId,
    if (redeemedAt != null) 'redeemedAt': toWireDateTime(redeemedAt!),
    if (releasedAt != null) 'releasedAt': toWireDateTime(releasedAt!),
  };

  // --- UI Helpers ---

  /// The promo slot was returned when the booking was cancelled.
  bool get isReleased => releasedAt != null;

  /// SAR saved on this booking, from the halala amount.
  double get discount => discountMinor / 100.0;

  /// Nothing to render: no code came back, or it granted nothing.
  bool get isEmpty => (code == null || code!.isEmpty) || discountMinor <= 0;
}
