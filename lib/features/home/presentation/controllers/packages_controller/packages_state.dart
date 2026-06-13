part of 'packages_cubit.dart';

sealed class PackagesState extends Equatable {
  const PackagesState();

  @override
  List<Object?> get props => [];
}

final class PackagesInitial extends PackagesState {}

final class PackagesLoading extends PackagesState {}

final class PackagesLoaded extends PackagesState {
  final List<PackageModel> packages;

  const PackagesLoaded(this.packages);

  @override
  List<Object?> get props => [packages];
}

final class PackagesError extends PackagesState {
  final String message;

  const PackagesError(this.message);

  @override
  List<Object?> get props => [message];
}
