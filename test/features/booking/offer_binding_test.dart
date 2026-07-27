import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/address/data/models/address_model.dart';
import 'package:aqua_go/features/booking/data/data_sources/bookings_remote_data_source.dart';
import 'package:aqua_go/features/booking/data/models/quote_model.dart';
import 'package:aqua_go/core/utils/saudi_wire_format.dart';
import 'package:aqua_go/features/booking/data/models/service_booking_request_model.dart';
import 'package:aqua_go/features/booking/data/repos/booking_repository.dart';
import 'package:aqua_go/features/booking/domain/strategies/service_booking_submit.dart';
import 'package:aqua_go/features/booking/presentation/controllers/booking_state.dart';
import 'package:aqua_go/features/home/data/models/service_model.dart';
import 'package:aqua_go/features/my_bookings/data/models/booking_response_model/booking_response_model.dart';
import 'package:aqua_go/features/my_cars/data/models/my_car_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/promo_summary_harness.dart';

/// An offer-driven booking must reach the server as an `offerId`, NOT as the
/// bare code the offer happens to carry. The server resolves the offer's linked
/// promo code itself and stamps `promo_redemptions.offer_id`, which is the only
/// thing that can attribute a sale to an offer (two live offers may link the
/// same code, UCA22 A6). Sending the code instead silently drops that
/// attribution — the booking still gets its discount, so nothing looks broken.
///
/// `offerId` and `promoCode` are alternatives on both the quote and the create
/// call: sending both is a 400 (`promo-and-offer-mutually-exclusive`).
void main() {
  group('quote request', () {
    test('an offer sends offerId ONLY — never the code alongside it', () async {
      final api = _RecordingApiClient();
      await BookingsRemoteDataSource(api).getQuote(
        packageId: 'pkg-1',
        lat: 21.4858,
        lng: 39.1925,
        offerId: 'offer-1',
      );

      expect(api.lastPath, Endpoints.quotes);
      expect(api.lastBody!['offerId'], 'offer-1');
      expect(
        api.lastBody!.containsKey('promoCode'),
        isFalse,
        reason: 'offerId + promoCode together is a 400',
      );
    });

    test('a typed code sends promoCode ONLY', () async {
      final api = _RecordingApiClient();
      await BookingsRemoteDataSource(api).getQuote(
        packageId: 'pkg-1',
        lat: 21.4858,
        lng: 39.1925,
        promoCode: 'WELCOME20',
      );

      expect(api.lastBody!['promoCode'], 'WELCOME20');
      expect(api.lastBody!.containsKey('offerId'), isFalse);
    });

    test('an offer wins when both are somehow supplied', () async {
      final api = _RecordingApiClient();
      await BookingsRemoteDataSource(api).getQuote(
        packageId: 'pkg-1',
        lat: 21.4858,
        lng: 39.1925,
        promoCode: 'WELCOME20',
        offerId: 'offer-1',
      );

      // The pair is a 400. The client must never send it, whatever it is
      // handed: the offer is the richer binding, so it is the one that stands.
      expect(api.lastBody!['offerId'], 'offer-1');
      expect(api.lastBody!.containsKey('promoCode'), isFalse);
    });

    test('no promo at all sends neither key', () async {
      final api = _RecordingApiClient();
      await BookingsRemoteDataSource(api).getQuote(
        packageId: 'pkg-1',
        lat: 21.4858,
        lng: 39.1925,
      );

      expect(api.lastBody!.containsKey('promoCode'), isFalse);
      expect(api.lastBody!.containsKey('offerId'), isFalse);
    });
  });

  group('booking create request', () {
    test('carries the offer the quote was priced with', () {
      final json = ServiceBookingRequestModel(
        quote: _quote,
        offerId: 'offer-1',
        moyasarPaymentId: 'pay_1',
      ).toJson();

      expect(json['offerId'], 'offer-1');
    });

    test('omits offerId for a manually typed code', () {
      final json = ServiceBookingRequestModel(
        quote: _quote,
        moyasarPaymentId: 'pay_1',
      ).toJson();

      expect(json.containsKey('offerId'), isFalse);
    });
  });

  group('ServiceBookingSubmit', () {
    // The strategy reads the stored language out of CacheClient to localise the
    // biker notes it puts on the wire, so the preference store has to exist
    // before submit() runs.
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await CacheClient.init();
    });

    test('forwards the applied offer id from the booking state', () async {
      final repo = _CapturingRepo();
      await ServiceBookingSubmit().submit(
        repo: repo,
        state: BookingState(
          selectedService: ServiceModel(id: 'pkg-1'),
          selectedCar: MyCarModel(id: 'car-1', color: '0xFF000000'),
          selectedAddress: AddressModel(
            id: 'addr-1',
            label: 'Home',
            details: 'Jeddah',
            lat: 21.4858,
            lng: 39.1925,
          ),
          quote: _quote,
          appliedPromoCode: 'WELCOME20',
          appliedOfferId: 'offer-1',
        ),
        moyasarPaymentId: 'pay_1',
      );

      expect(repo.captured!.toJson()['offerId'], 'offer-1');
    });
  });

  group('offer attribution on the cubit', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await CacheClient.init();
    });

    test('a typed code applied over a live offer drops the attribution', () async {
      final cubit = buildCubit(RecordingBookingRepo());
      addTearDown(cubit.close);

      await cubit.applyOffer('offer-1');
      expect(cubit.state.appliedOfferId, 'offer-1');

      // The customer types a different code over the offer. The quote that
      // comes back was priced with NO offer, so the booking must not be
      // stamped with one — `promo_redemptions.offer_id` is the whole of the
      // sale attribution, and this sale did not come through that offer.
      await cubit.applyPromoCode('OTHERCODE');

      expect(cubit.state.appliedPromoCode, 'OTHERCODE');
      expect(
        cubit.state.appliedOfferId,
        isNull,
        reason: 'the offer the customer did not come through must not be '
            'credited with the sale',
      );
    });

    test('an offer-driven reprice keeps the attribution', () async {
      final cubit = buildCubit(RecordingBookingRepo());
      addTearDown(cubit.close);

      await cubit.applyOffer('offer-1');
      await cubit.reprice();

      expect(cubit.state.appliedOfferId, 'offer-1');
    });
  });
}

final _quote = QuoteModel(
  quoteId: 'quote-1',
  totalMinor: 9500,
  vatMinor: 1239,
  currency: 'SAR',
  expiresAt: saudiNow().add(const Duration(minutes: 15)),
  promoCode: 'WELCOME20',
  promoDiscountMinor: 2000,
);

/// Captures the body each call would put on the wire, and answers with an
/// empty success so the caller's mapping runs to completion.
class _RecordingApiClient extends APIClient {
  _RecordingApiClient() : super(Dio());

  String? lastPath;
  Map<String, dynamic>? lastBody;

  @override
  Future<Either<Failure, T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) async {
    lastPath = path;
    lastBody = data as Map<String, dynamic>?;
    return Right<Failure, T>(<String, dynamic>{} as T);
  }
}

class _CapturingRepo extends BookingRepository {
  _CapturingRepo()
    : super(
        bookingsRemoteDataSource: BookingsRemoteDataSource(APIClient(Dio())),
      );

  ServiceBookingRequestModel? captured;

  @override
  Future<Either<Failure, BookingResponseModel>> createBooking(
    ServiceBookingRequestModel booking,
  ) async {
    captured = booking;
    return left(ServerFailure('not exercised'));
  }
}
