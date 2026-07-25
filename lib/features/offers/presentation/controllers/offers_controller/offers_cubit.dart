import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/customer_offer_model.dart';
import '../../../data/repos/offers_repository.dart';

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
}
