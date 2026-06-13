part of 'banners_cubit.dart';

sealed class BannersState extends Equatable {
  const BannersState();

  @override
  List<Object?> get props => [];
}

final class BannersInitial extends BannersState {}

final class BannersLoading extends BannersState {}

final class BannersLoaded extends BannersState {
  final List<BannerModel> banners;

  const BannersLoaded(this.banners);

  @override
  List<Object?> get props => [banners];
}

final class BannersError extends BannersState {
  final String message;

  const BannersError(this.message);

  @override
  List<Object?> get props => [message];
}
