/// Wire-format helpers for the backend's date/time contract.
///
/// The backend emits and accepts **bare Asia/Riyadh local ISO-8601** — no
/// offset, no `Z` (`SaudiTimeSerializers`, registered globally in
/// `LenientJacksonConfig`; symmetric inbound in `LenientInstantDeserializer`).
///
/// These helpers build that shape by hand rather than through `DateFormat`
/// because `DateFormat` resolves `Intl.defaultLocale`, and a locale that
/// declares a `ZERODIGIT` (`bn`, `fa`, `ne`, `as`, `mr`, `my`, `ps`) would make
/// it emit Arabic-Indic digits — on a **wire** value the server has to parse.
library;

/// Asia/Riyadh is a fixed UTC+3 offset; the Kingdom observes no daylight saving.
const Duration _riyadhOffset = Duration(hours: 3);

String _pad2(int value) => value.toString().padLeft(2, '0');

/// `yyyy-MM-dd` — the shape the availability endpoint's `date` query parameter
/// takes. Always ASCII digits, whatever the device or app locale.
String toWireDate(DateTime dateTime) =>
    '${dateTime.year.toString().padLeft(4, '0')}'
    '-${_pad2(dateTime.month)}'
    '-${_pad2(dateTime.day)}';

/// `yyyy-MM-ddTHH:mm:ss` — the shape `scheduledAt` / `newScheduledAt` take.
///
/// The wall-clock fields of [dateTime] are written verbatim: an availability
/// slot parsed from the bare-local wire value round-trips back unchanged.
String toWireDateTime(DateTime dateTime) =>
    '${toWireDate(dateTime)}'
    'T${_pad2(dateTime.hour)}'
    ':${_pad2(dateTime.minute)}'
    ':${_pad2(dateTime.second)}';

/// "Now" as an Asia/Riyadh wall clock, so a device in any timezone builds the
/// same bare-local wire value the backend expects.
///
/// The result is UTC-FLAGGED and carries Riyadh wall-clock FIELDS. That pairing
/// is the frame every value in this library lives in — see
/// [tryParseWireDateTime] for why it has to be a single frame.
DateTime saudiNow() => DateTime.now().toUtc().add(_riyadhOffset);

/// True when [raw]'s time part is ANCHORED — it names a real instant with a
/// trailing `Z` or an explicit `±HH:mm` — rather than a bare wall clock.
///
/// Only the part after `T` is inspected: `2026-08-01` is full of hyphens and
/// none of them is an offset.
bool _isAnchored(String raw) {
  final time = raw.substring(raw.indexOf('T') + 1);
  return RegExp(r'([Zz]|[+-]\d{2}:?\d{2})$').hasMatch(time);
}

/// Parses a backend timestamp into the same frame [saudiNow] produces: a
/// UTC-flagged [DateTime] carrying Asia/Riyadh wall-clock fields.
///
/// Dart's [DateTime] is either local or UTC — there is no third "Riyadh"
/// flavour — and `isAfter`, `compareTo` and `difference` all compare
/// `microsecondsSinceEpoch`. So two values only answer the same on every device
/// if both sit in ONE frame, and this library's frame is UTC-flagged Riyadh
/// fields. Anchoring both sides is the whole fix; a `.toUtc()` on an already
/// device-local value is a no-op that changes nothing.
///
/// `DateTime.parse` alone is NOT this frame. On the bare, offset-less value the
/// backend actually sends it returns a DEVICE-LOCAL [DateTime], so the instant
/// it carries slides with the device's timezone: an offer ending at Riyadh
/// midnight stays visible three hours too long on a UTC phone and vanishes six
/// hours early in Tokyo. Bare-local is emitted precisely so that a plain
/// parse-and-reframe is device-independent (`SaudiTimeSerializers` on the
/// backend documents the same contract from the other side).
///
/// An anchored value — one that carries `Z` or an offset, which a local
/// round-trip through [DateTime.toIso8601String] produces — already names a
/// real instant, so it is converted to the Riyadh wall clock rather than read
/// verbatim.
///
/// Returns null for an absent or unparseable value. Read-reconstruction paths
/// pick their own fallback instead of being handed one, and none of them may
/// throw.
DateTime? tryParseWireDateTime(String? raw) {
  if (raw == null) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return null;
  final riyadh = _isAnchored(raw) ? parsed.toUtc().add(_riyadhOffset) : parsed;
  return DateTime.utc(
    riyadh.year,
    riyadh.month,
    riyadh.day,
    riyadh.hour,
    riyadh.minute,
    riyadh.second,
    riyadh.millisecond,
    riyadh.microsecond,
  );
}
