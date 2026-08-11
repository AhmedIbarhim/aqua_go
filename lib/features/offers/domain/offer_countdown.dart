enum OfferCountdownUnit { days, hours, minutes }

class OfferCountdown {
  const OfferCountdown(this.unit, this.value);

  final OfferCountdownUnit unit;

  final int value;

  @override
  bool operator ==(Object other) =>
      other is OfferCountdown && other.unit == unit && other.value == value;

  @override
  int get hashCode => Object.hash(unit, value);

  @override
  String toString() => 'OfferCountdown($unit, $value)';
}

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
