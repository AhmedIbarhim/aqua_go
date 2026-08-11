import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/config/networking/exceptions/failure.dart';
import '../../../data/models/customer_offer_model.dart';
import '../../../data/repos/offers_repository.dart';
import '../../../domain/offer_revalidation.dart';

part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  final OffersRepository _offersRepository;

  OffersCubit({required OffersRepository offersRepository})
    : _offersRepository = offersRepository,
      super(OffersInitial());

  Future<void> getOffers() async {
    emit(OffersLoading());
    final result = await _offersRepository.fetchOffers();
    result.fold(
      (failure) => emit(OffersError(failure.message)),
      (offers) => emit(OffersLoaded(List.from(offers))),
    );
  }

  Future<OfferRevalidation> revalidateOffer(String offerId) async {
    final result = await _offersRepository.fetchOffer(offerId);
    return result.fold((failure) async {
      if (failure.type != FailureType.notFound) {
        return const OfferUncheckable();
      }
      await getOffers();
      return const OfferGone();
    }, (offer) async => OfferStillLive(offer));
  }
}
