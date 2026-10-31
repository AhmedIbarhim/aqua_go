import 'package:aqua_go/features/booking/data/mappers/subscription_catalog_mapper.dart';
import 'package:aqua_go/features/booking/data/mappers/wash_preview_quote_mapper.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_state.dart';
import 'package:aqua_go/features/home/data/models/add_on_model.dart';
import 'package:aqua_go/features/home/data/models/service_model.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

SubscriptionResponseModel _subscription({
  List<Map<String, dynamic>> washes = const [],
  List<Map<String, dynamic>> addons = const [],
  List<Map<String, dynamic>> allowances = const [],
}) => SubscriptionResponseModel.fromJson({
  'packageId': 'pkg-1',
  'packageInfo': {'addons': addons},
  'washes': washes,
  'includedAllowances': allowances,
});

void main() {
  group('subscriptionCatalogFrom', () {
    test('no bookable wash means no catalog', () {
      final subscription = _subscription(
        washes: [
          {'washId': 'w1', 'canSchedule': false},
        ],
      );

      expect(subscriptionCatalogFrom(subscription), isNull);
    });

    test('the requested wash wins over the first schedulable one', () {
      final subscription = _subscription(
        washes: [
          {'washId': 'w1', 'canSchedule': true},
          {'washId': 'w2', 'canSchedule': false},
        ],
      );

      final catalog = subscriptionCatalogFrom(
        subscription,
        preferredWashId: 'w2',
      );

      expect(catalog?.washId, 'w2');
    });

    test('an included add-on is free only while its allowance lasts', () {
      final subscription = _subscription(
        washes: [
          {'washId': 'w1', 'canSchedule': true},
        ],
        addons: [
          {'id': 'free', 'kind': 'INCLUDED', 'priceMinor': 500},
          {'id': 'spent', 'kind': 'INCLUDED', 'priceMinor': 700},
          {'id': 'paid', 'kind': 'OPTIONAL', 'priceMinor': 900},
        ],
        allowances: [
          {
            'addonId': 'free',
            'totalQty': 2,
            'consumedQty': 1,
            'remainingQty': 1,
          },
          {
            'addonId': 'spent',
            'totalQty': 1,
            'consumedQty': 1,
            'remainingQty': 0,
          },
        ],
      );

      final catalog = subscriptionCatalogFrom(subscription)!;

      expect(catalog.service.addons.map((a) => a.priceMinor), [0, 700, 900]);
      expect(catalog.includedAddonIds, {'free', 'spent'});
      expect(catalog.optionalAddonIds, {'paid'});
    });
  });

  group('washPreviewQuoteFrom', () {
    test('the net lines always add up to the breakdown net', () {
      final quote = washPreviewQuoteFrom({
        'chargeTotalMinor': 1000,
        'breakdown': {'grossMinor': 1000, 'netMinor': 869, 'currency': 'SAR'},
        'addonLines': [
          {'addonId': 'a', 'chargedMinor': 333},
          {'addonId': 'free', 'chargedMinor': 0},
          {'addonId': 'b', 'chargedMinor': 667},
        ],
      });

      final nets = quote.lines.map((l) => l.netMinor).toList();
      expect(nets.reduce((a, b) => a + b), 869);
      expect(nets[1], 0);
    });

    test('with no breakdown the charge total stands in for it', () {
      final quote = washPreviewQuoteFrom({'chargeTotalMinor': '1200'});

      expect(quote.breakdown?.totalMinor, 1200);
      expect(quote.breakdown?.grossMinor, 1200);
      expect(quote.currency, 'SAR');
      expect(quote.lines, isEmpty);
    });
  });

  test('selectedAddonIds skips stale indices and id-less add-ons', () {
    final state = BookingState(
      selectedService: ServiceModel(
        addons: [
          AddOnModel(id: 'a'),
          AddOnModel(),
        ],
      ),
      selectedServiceIndices: const {0, 1, 9},
    );

    expect(state.selectedAddonIds, ['a']);
  });
}
