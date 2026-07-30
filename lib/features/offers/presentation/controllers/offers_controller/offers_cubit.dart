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

  /// UCC23 A2 — re-checks [offerId] at the moment the customer commits to it.
  ///
  /// "Offer expires while the customer is viewing its detail page → on tapping
  /// the primary action, the system re-validates, blocks the action and returns
  /// the customer to a refreshed list with a brief toast." Eligibility is
  /// evaluated at request time and never cached (BR-OFR-11), so the copy the
  /// list handed to the detail screen is only as fresh as the moment it was
  /// fetched — which may be minutes of reading ago.
  ///
  /// On [OfferGone] the list is refreshed HERE, before returning, so the screen
  /// the customer is sent back to is already the corrected one rather than one
  /// that still shows the offer for a frame.
  Future<OfferRevalidation> revalidateOffer(String offerId) async {
    final result = await _offersRepository.fetchOffer(offerId);
    return result.fold(
      (failure) async {
        if (failure.type != FailureType.notFound) {
          // Transport failure, not a verdict. Do not invent an expiry.
          return const OfferUncheckable();
        }
        await getOffers();
        return const OfferGone();
      },
      (offer) async => OfferStillLive(offer),
    );
  }
}
