/// Days remaining before an offer ends, or `null` when no "Ends in N days"
/// chip should be rendered.
///
/// The chip appears only when strictly fewer than 7 days remain (UCC23). The
/// value is rounded UP so a part-day always reads as a whole day, and floored
/// at 1 so an offer ending in minutes never reads as "Ends in 0 days".
/// Both instants are normalised to UTC before subtracting so a device in
/// Asia/Riyadh and a UTC `endsAt` from the API cannot drift by the offset.
int? offerEndsInDays(DateTime endsAt, DateTime now) {
  final remaining = endsAt.toUtc().difference(now.toUtc());
  if (remaining <= Duration.zero) return null;
  if (remaining >= const Duration(days: 7)) return null;
  final days = (remaining.inMinutes / (60 * 24)).ceil();
  return days < 1 ? 1 : days;
}
