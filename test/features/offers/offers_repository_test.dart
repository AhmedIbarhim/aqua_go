import 'package:aqua_go/core/config/networking/api_client.dart';
import 'package:aqua_go/core/config/networking/endpoints.dart';
import 'package:aqua_go/core/config/networking/exceptions/failure.dart';
import 'package:aqua_go/features/offers/data/data_source/offers_remote_data_source.dart';
import 'package:aqua_go/features/offers/data/repos/offers_repository.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOffersDataSource extends OffersRemoteDataSource {
  _FakeOffersDataSource(this._result) : super(APIClient(Dio()));

  final Either<Failure, dynamic> _result;

  @override
  Future<Either<Failure, dynamic>> getOffers() async => _result;

  @override
  Future<Either<Failure, dynamic>> getOffer(String offerId) async => _result;
}

Map<String, dynamic> offerJson(String id) => {
      'id': id,
      'offerType': 'PROMO_CODE',
      'titleAr': 'عنوان',
      'titleEn': 'Title',
      'descriptionAr': 'وصف',
      'descriptionEn': 'Desc',
      'endsAt': '2026-09-01T00:00:00',
      'terms': {
        'promoCode': 'X',
        'discountType': 'PERCENTAGE',
        'configuredValue': 10,
      },
    };

void main() {
  group('Endpoints.publicUrl', () {
    test('swaps the customer segment for the public one', () {
      expect(
        Endpoints.publicUrl('https://qa-api.aquago.sa/api/customer/', Endpoints.publicOffers),
        'https://qa-api.aquago.sa/api/public/offers',
      );
      expect(
        Endpoints.publicUrl('https://api.aquago.sa/api/customer/', Endpoints.publicOffer('abc')),
        'https://api.aquago.sa/api/public/offers/abc',
      );
    });
  });

  group('OffersRepository.fetchOffers', () {
    test('maps a JSON list into CustomerOfferModels', () async {
      final repo = OffersRepository(
        _FakeOffersDataSource(Right<Failure, dynamic>([offerJson('a'), offerJson('b')])),
      );
      final result = await repo.fetchOffers();
      expect(result.isRight(), isTrue);
      final offers = result.getOrElse(() => []);
      expect(offers.length, 2);
      expect(offers.first.id, 'a');
      expect(offers.first.terms.discountType, 'PERCENTAGE');
    });

    test('an empty list is a success, not a failure', () async {
      final repo = OffersRepository(_FakeOffersDataSource(Right<Failure, dynamic>(<dynamic>[])));
      final result = await repo.fetchOffers();
      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []), isEmpty);
    });

    test('propagates the data-source failure untouched', () async {
      final repo = OffersRepository(
        _FakeOffersDataSource(const Left<Failure, dynamic>(ServerFailure('boom'))),
      );
      final result = await repo.fetchOffers();
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f.message, 'boom'), (_) => fail('expected a Left'));
    });

    test('a non-list payload becomes a ServerFailure the customer can read',
        () async {
      final repo = OffersRepository(
        _FakeOffersDataSource(Right<Failure, dynamic>({'not': 'a list'})),
      );
      final result = await repo.fetchOffers();
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) {
          // `Failure.message` is customer-facing, so it is the localized
          // generic and nothing else. The exception detail — English, and the
          // shape of whatever payload came back — goes to the log.
          expect(f.message, LocaleKeys.snackbar_default_error);
          expect(f.message, isNot(contains('type')));
          expect(f.message, isNot(contains('Exception')));
        },
        (_) => fail('expected a Left'),
      );
    });
  });

  group('OffersRepository.fetchOffer', () {
    test('maps a single JSON object into a CustomerOfferModel', () async {
      final repo = OffersRepository(
        _FakeOffersDataSource(Right<Failure, dynamic>(offerJson('solo'))),
      );
      final result = await repo.fetchOffer('solo');
      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => throw StateError('left')).id, 'solo');
    });

    test('propagates the 404 Left for an ineligible or absent offer', () async {
      final repo = OffersRepository(
        _FakeOffersDataSource(const Left<Failure, dynamic>(ServerFailure('not found'))),
      );
      final result = await repo.fetchOffer('gone');
      expect(result.isLeft(), isTrue);
    });
  });
}
