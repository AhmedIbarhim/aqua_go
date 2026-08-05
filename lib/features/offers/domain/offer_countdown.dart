/// The unit an offer's urgency chip is stated in.
///
/// Three tiers, because one was not enough. The chip used to carry only
/// [OfferCountdownUnit.days] and floored at 1, so an offer with five minutes
/// left read "Ends in 1 day" (AQG-437). The clamp was correct for a days-only
/// chip — "Ends in 0 days" is worse — so the fix is to give the chip smaller
/// units, not to remove the floor.
enum OfferCountdownUnit { days, hours, minutes }

/// How long an offer has left, in the largest unit that still reads true.
class OfferCountdown {
  const OfferCountdown(this.unit, this.value);

  final OfferCountdownUnit unit;

  /// Always >= 1. A tier never yields 0 — a chip that says "0" is a chip
  /// that should not have been drawn, and [offerCountdown] returns null for
  /// that case instead.
  final int value;

  @override
  bool operator ==(Object other) =>
      other is OfferCountdown && other.unit == unit && other.value == value;

  @override
  int get hashCode => Object.hash(unit, value);

  @override
  String toString() => 'OfferCountdown($unit, $value)';
}

/// Time remaining before an offer ends, or `null` when no urgency chip should
/// be rendered at all.
///
/// The chip appears only when strictly fewer than 7 days remain (UCC23).
///
/// **Rounding is deliberately asymmetric.** The DAYS tier rounds UP, which is
/// the behaviour that shipped and is locked by test: a part-day reads as a
/// whole day. The HOURS and MINUTES tiers round DOWN, because rounding up
/// there OVERSTATES the time left — 23h59m would print "Ends in 24 hours",
/// and a countdown that tells the customer they have more time than they do
/// is the one error that costs them the offer. Both sub-day tiers floor at 1
/// for the same reason the days tier did.
///
/// Both arguments MUST be in the Riyadh frame — `endsAt` as parsed by
/// [tryParseWireDateTime], [now] as `saudiNow()`. `difference` subtracts epoch
/// microseconds, so mixing frames shifts the chip by the device's offset and
/// makes it read a day early or late at the boundary.
OfferCountdown? offerCountdown(DateTime endsAt, DateTime now) {
  final remaining = endsAt.difference(now);
  if (remaining <= Duration.zero) return null;
  if (remaining >= const Duration(days: 7)) return null;

  if (remaining >= const Duration(days: 1)) {
    return OfferCountdown(
      OfferCountdownUnit.days,
      (remaining.inMinutes / (60 * 24)).ceil(),
    );
  }
  if (remaining >= const Duration(hours: 1)) {
    return OfferCountdown(OfferCountdownUnit.hours, remaining.inHours);
  }
  final minutes = remaining.inMinutes;
  return OfferCountdown(OfferCountdownUnit.minutes, minutes < 1 ? 1 : minutes);
}
