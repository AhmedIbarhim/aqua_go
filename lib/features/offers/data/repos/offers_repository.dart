import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../../generated/locale_keys.g.dart';
import '../data_source/offers_remote_data_source.dart';
import '../models/customer_offer_model.dart';

class OffersRepository {
  final OffersRemoteDataSource _offersDataSource;

  OffersRepository(this._offersDataSource);

  /// A payload this client could not read. `Failure.message` is customer-facing
  /// text, so it carries the localized generic and nothing else — an exception
  /// string is developer detail, in English, and belongs in the log
  /// (`server_failure.dart` states the same rule for the 404 path).
  static ServerFailure _unreadable(Object error, StackTrace stackTrace) {
    developer.log(
      'Offers parsing exception: $error',
      error: error,
      stackTrace: stackTrace,
    );
    return ServerFailure(LocaleKeys.snackbar_default_error.tr());
  }

  /// GET /api/public/offers — already ordered endsAt ASC by the backend, so the
  /// wire order is preserved verbatim (no client-side re-sort here; the offers
  /// screen re-sorts defensively for its own contract).
  Future<Either<Failure, List<CustomerOfferModel>>> fetchOffers() async {
    final result = await _offersDataSource.getOffers();
    return result.fold((failure) => Left(failure), (data) {
      try {
        final List<dynamic> list = data as List<dynamic>;
        final parsed = list
            .map((json) => CustomerOfferModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(parsed);
      } catch (e, stackTrace) {
        return Left(_unreadable(e, stackTrace));
      }
    });
  }

  /// GET /api/public/offers/{id} — the backend returns 404 for an INELIGIBLE
  /// offer as well as an ABSENT one (deliberately indistinguishable, UCC23), so
  /// the caller must render one neutral "offer unavailable" state for the Left.
  Future<Either<Failure, CustomerOfferModel>> fetchOffer(String offerId) async {
    final result = await _offersDataSource.getOffer(offerId);
    return result.fold((failure) => Left(failure), (data) {
      try {
        return Right(CustomerOfferModel.fromJson(data as Map<String, dynamic>));
      } catch (e, stackTrace) {
        return Left(_unreadable(e, stackTrace));
      }
    });
  }
}
