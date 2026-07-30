import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_summary_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // `fromDetails` reads the persisted language through `BookingVehicle.makeName`
  // to pick a localised make, so the cache has to exist before it runs.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheClient.init();
  });

  group('BookingSummaryModel.fromJson', () {
    test('parses the fields the list endpoint actually sends', () {
      final summary = BookingSummaryModel.fromJson({
        'id': 'booking-1',
        'referenceNumber': 'BK-000123',
        'type': 'SCHEDULED',
        'status': 'PENDING',
        'currency': 'SAR',
        'isSubscription': true,
        'subscriptionSequence': 3,
        'workerNotes': ['Gate code 4412', 'Park by the second tower'],
        'addressArrivalNotes': 'Ring the intercom',
        'breakdown': {
          'grossMinor': 5175,
          'netMinor': 4500,
          'vatMinor': 675,
          'currency': 'SAR',
        },
      });
      // referenceNumber is REQUIRED on the wire; the list could not show one
      // without a per-row detail fetch until it was parsed here.
      expect(summary.referenceNumber, 'BK-000123');
      expect(summary.subscriptionSequence, 3);
      expect(summary.workerNotes, [
        'Gate code 4412',
        'Park by the second tower',
      ]);
      expect(summary.addressArrivalNotes, 'Ring the intercom');
      expect(summary.breakdown?.grossMinor, 5175);
      expect(summary.breakdown?.net, 45.0);
    });

    test('a non-list workerNotes degrades to null instead of throwing', () {
      // Read-reconstruction path: stored data must keep reading.
      final summary = BookingSummaryModel.fromJson({
        'id': 'booking-2',
        'workerNotes': 'Gate code 4412',
        'breakdown': 'not-an-object',
      });
      expect(summary.workerNotes, isNull);
      expect(summary.breakdown, isNull);
    });

    test('the absent fields stay null rather than defaulting', () {
      final summary = BookingSummaryModel.fromJson({'id': 'booking-3'});
      expect(summary.referenceNumber, isNull);
      expect(summary.subscriptionSequence, isNull);
      expect(summary.workerNotes, isNull);
      expect(summary.addressArrivalNotes, isNull);
      expect(summary.breakdown, isNull);
    });
  });

  test('the new fields survive the round-trip through the details model', () {
    // Both bridges are lossy by omission, and a field dropped in either one is
    // a field the detail screen silently loses on a list-to-detail hand-off.
    final summary = BookingSummaryModel.fromJson({
      'id': 'booking-4',
      'referenceNumber': 'BK-000456',
      'workerNotes': ['Gate code 4412'],
      'addressArrivalNotes': 'Ring the intercom',
      'breakdown': {'grossMinor': 5175, 'netMinor': 4500, 'vatMinor': 675},
    });
    final details = summary.toDetailsPlaceholder();
    expect(details.referenceNumber, 'BK-000456');
    expect(details.workerNotes, ['Gate code 4412']);
    expect(details.addressArrivalNotes, 'Ring the intercom');
    expect(details.breakdown?.grossMinor, 5175);

    final back = BookingSummaryModel.fromDetails(details);
    expect(back.referenceNumber, 'BK-000456');
    expect(back.workerNotes, ['Gate code 4412']);
    expect(back.addressArrivalNotes, 'Ring the intercom');
    expect(back.breakdown?.grossMinor, 5175);
  });
}
