import 'package:dartz/dartz.dart';

import '../../../../core/config/networking/exceptions/failure.dart';
import '../data_source/offers_remote_data_source.dart';
import '../models/customer_offer_model.dart';

class OffersRepository {
  final OffersRemoteDataSource _offersDataSource;

  OffersRepository(this._offersDataSource);

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
      } catch (e) {
        return Left(ServerFailure('Parsing error: $e'));
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
      } catch (e) {
        return Left(ServerFailure('Parsing error: $e'));
      }
    });
  }
}
