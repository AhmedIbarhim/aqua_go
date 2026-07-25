part of 'offers_cubit.dart';

sealed class OffersState extends Equatable {
  const OffersState();

  @override
  List<Object?> get props => [];
}

final class OffersInitial extends OffersState {}

final class OffersLoading extends OffersState {}

final class OffersLoaded extends OffersState {
  final List<CustomerOfferModel> offers;

  const OffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

final class OffersError extends OffersState {
  final String message;

  const OffersError(this.message);

  @override
  List<Object?> get props => [message];
}
