import 'package:aqua_go/core/utils/date_time_formatter.dart';
import 'package:aqua_go/core/utils/saudi_wire_format.dart';
import 'package:aqua_go/features/booking/data/models/availability_response_model.dart';
import 'package:aqua_go/features/booking/data/models/package_booking_request_model.dart';
import 'package:aqua_go/features/booking/data/models/package_reschedule_request_model.dart';
import 'package:aqua_go/features/booking/data/models/service_booking_request_model.dart';
import 'package:aqua_go/features/booking/data/models/service_reschedule_request_model.dart';
import 'package:aqua_go/generated/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cover for AQG-392 (the booking wire path) and AQG-393 (the display path).
///
/// The app had ZERO date/time tests, which is why a 12-hour write-time
/// corruption shipped.
///
/// **Harness note.** A plain `test()` has no locale data at all — intl's
/// `UninitializedLocaleData` returns the fallback only for `en_US` and throws
/// `LocaleDataException` for anything else, so a naive unit test here would
/// throw rather than assert. Production loads its symbols from
/// `flutter_localizations`' `loadDateIntlDataIfNotLoaded()` via
/// `GlobalMaterialLocalizations`, reached here by pumping the same
/// `EasyLocalization` + `MaterialApp` scaffolding `launchApp` builds. That call
/// loads the WHOLE generated table in one go, so every locale asserted below —
/// including the ZERODIGIT ones — is the table production actually uses.
void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  tearDown(() {
    Intl.defaultLocale = null;
    Intl.systemLocale = 'en_US';
  });

  /// Loads the production date-symbol table by mounting the real localization
  /// delegates, exactly as `MyApp` does.
  Future<void> loadProductionDateSymbols(WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        assetLoader: const CodegenLoader(),
        child: Builder(
          builder: (context) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('AQG-393 — display follows the APP locale, not the device', () {
    testWidgets('an Arabic handset running the app in English reads English', (
      tester,
    ) async {
      await loadProductionDateSymbols(tester);
      final slot = DateTime(2026, 7, 23, 23, 0);

      // ORDERING IS THE WHOLE TEST. The device locale is installed FIRST —
      // exactly as `EasyLocalization.ensureInitialized()` does via
      // `findSystemLocale()` — and the app's pin must still win. Without this
      // ordering the assertion passes against the bug.
      Intl.systemLocale = 'ar_SA';
      Intl.defaultLocale = 'en';

      final time = formatClockTime(slot);
      expect(time, startsWith('11:00'));
      expect(time, contains('PM'));
      expect(time, isNot(contains('م')));
      expect(formatShortDate(slot), '7/23/2026');
    });

    testWidgets('the mirror case: English handset, app in Arabic', (
      tester,
    ) async {
      await loadProductionDateSymbols(tester);
      final slot = DateTime(2026, 7, 23, 23, 0);

      Intl.systemLocale = 'en_US';
      Intl.defaultLocale = 'ar';

      final time = formatClockTime(slot);
      expect(time, startsWith('11:00'));
      expect(time, contains('م'));
      expect(time, isNot(contains('PM')));
    });

    testWidgets('an unpinned locale falls back to Arabic, never the device', (
      tester,
    ) async {
      await loadProductionDateSymbols(tester);
      final slot = DateTime(2026, 7, 23, 23, 0);

      Intl.systemLocale = 'bn';
      Intl.defaultLocale = null;

      // The app boots Arabic-first (`fallbackLocale: ar`), so an unpinned
      // formatter must read Arabic — not the Bengali handset.
      expect(formatClockTime(slot), contains('م'));
      expect(formatClockTime(slot), startsWith('11:00'));
    });
  });

  group('AQG-392 — the slot instant reaches the wire unchanged', () {
    /// The service grid is `08:00 + 90·k` with a 23:00 last start. Under the
    /// old display-string round-trip a dropped meridiem sent every slot back
    /// 12 hours; 12:30–18:30 then landed off-grid and surfaced as a loud 422,
    /// but THESE THREE stayed on-grid and corrupted silently — 23:00 → 11:00 is
    /// the case in the ticket title.
    const gridPreservingSlots = <String>[
      '2026-07-23T20:00:00',
      '2026-07-23T21:30:00',
      '2026-07-23T23:00:00',
    ];

    /// Both app locales, plus a ZERODIGIT device locale that the old path would
    /// also have mangled.
    const locales = <String>['ar', 'en', 'bn'];

    testWidgets('every request model serialises the slot verbatim', (
      tester,
    ) async {
      await loadProductionDateSymbols(tester);

      for (final wire in gridPreservingSlots) {
        final slot = AvailabilitySlot.fromJson({
          'start': wire,
          'end': wire,
          'available': true,
        });

        for (final locale in locales) {
          Intl.defaultLocale = locale;
          final reason = 'slot $wire under locale $locale';

          expect(
            ServiceBookingRequestModel(slotStart: slot.start)
                .toJson()['scheduledAt'],
            wire,
            reason: reason,
          );
          expect(
            PackageBookingRequestModel(slotStart: slot.start)
                .toJson()['scheduledAt'],
            wire,
            reason: reason,
          );
          expect(
            ServiceRescheduleRequestModel(
              bookingId: 'bk-1',
              slotStart: slot.start,
            ).toJson()['newScheduledAt'],
            wire,
            reason: reason,
          );
          expect(
            PackageRescheduleRequestModel(
              slotStart: slot.start,
            ).toJson()['newScheduledAt'],
            wire,
            reason: reason,
          );
        }
      }
    });

    testWidgets('the display label diverges while the wire value does not', (
      tester,
    ) async {
      await loadProductionDateSymbols(tester);
      final slot = AvailabilitySlot.fromJson({
        'start': '2026-07-23T23:00:00',
        'end': '2026-07-24T00:30:00',
        'available': true,
      });

      Intl.defaultLocale = 'en';
      final englishLabel = formatClockTime(slot.start);
      final englishWire = toWireDateTime(slot.start);

      Intl.defaultLocale = 'ar';
      final arabicLabel = formatClockTime(slot.start);
      final arabicWire = toWireDateTime(slot.start);

      // The labels legitimately differ per locale...
      expect(arabicLabel, isNot(englishLabel));
      // ...and that is precisely why nothing may parse them back.
      expect(englishWire, '2026-07-23T23:00:00');
      expect(arabicWire, englishWire);
    });

    testWidgets('midnight stays midnight instead of becoming noon', (
      tester,
    ) async {
      await loadProductionDateSymbols(tester);
      const wire = '2026-07-23T00:00:00';
      final slot = AvailabilitySlot.fromJson({
        'start': wire,
        'end': wire,
        'available': true,
      });

      for (final locale in locales) {
        Intl.defaultLocale = locale;
        // The old marker matcher recognised neither flag in "12:00 AM", left
        // the hour at 12, and booked noon.
        expect(
          ServiceBookingRequestModel(
            slotStart: slot.start,
          ).toJson()['scheduledAt'],
          wire,
          reason: 'midnight under locale $locale',
        );
      }
    });

    testWidgets('the reschedule prefill, which bypasses the picker, is exact', (
      tester,
    ) async {
      await loadProductionDateSymbols(tester);
      const storedScheduledAt = '2026-07-23T23:00:00';

      for (final locale in locales) {
        Intl.defaultLocale = locale;

        // Exactly what `my_booking_details_view` now carries into the flow:
        // the parsed booking time, structurally, with no display label between
        // the stored value and the reschedule request.
        final existingSlotStart = DateTime.tryParse(storedScheduledAt);
        expect(existingSlotStart, isNotNull);

        expect(
          ServiceRescheduleRequestModel(
            bookingId: 'bk-1',
            slotStart: existingSlotStart!,
          ).toJson()['newScheduledAt'],
          storedScheduledAt,
          reason: 'reschedule prefill under locale $locale',
        );
      }
    });
  });

  group('wire values stay ASCII whatever the locale', () {
    /// The locales that declare a ZERODIGIT in Flutter's generated table.
    /// `ar_EG` is deliberately NOT used: it is absent from that table, so it
    /// would make this a guaranteed false negative.
    const zeroDigitLocales = <String>['as', 'bn', 'fa', 'mr', 'my', 'ne', 'ps'];

    final asciiDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    final asciiDateTime = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$');

    testWidgets('the availability date parameter and scheduledAt are ASCII', (
      tester,
    ) async {
      await loadProductionDateSymbols(tester);
      final date = DateTime(2026, 7, 23, 23, 0);

      for (final locale in zeroDigitLocales) {
        Intl.defaultLocale = locale;

        expect(toWireDate(date), matches(asciiDate), reason: locale);
        expect(toWireDateTime(date), matches(asciiDateTime), reason: locale);

        // Control: prove the locale really does substitute native digits, so
        // the two assertions above cannot pass vacuously.
        expect(
          DateFormat('yyyy-MM-dd', locale).format(date),
          isNot(matches(asciiDate)),
          reason: '$locale must declare a ZERODIGIT for this guard to bite',
        );
      }
    });
  });
}
