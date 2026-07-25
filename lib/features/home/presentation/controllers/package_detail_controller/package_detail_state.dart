part of 'package_detail_cubit.dart';

sealed class PackageDetailState extends Equatable {
  const PackageDetailState();

  @override
  List<Object?> get props => [];
}

final class PackageDetailInitial extends PackageDetailState {}

final class PackageDetailLoading extends PackageDetailState {}

final class PackageDetailLoaded extends PackageDetailState {
  final PackageModel package;

  const PackageDetailLoaded(this.package);

  @override
  List<Object?> get props => [package.id];
}

/// The id resolved against the public catalogue but is no longer active.
final class PackageDetailNotFound extends PackageDetailState {}

final class PackageDetailError extends PackageDetailState {
  final String message;

  const PackageDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
