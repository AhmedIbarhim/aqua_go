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
DateTime saudiNow() => DateTime.now().toUtc().add(_riyadhOffset);
