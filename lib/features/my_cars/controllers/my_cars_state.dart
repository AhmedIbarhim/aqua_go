part of 'my_cars_cubit.dart';

sealed class MyCarsState extends Equatable {
  const MyCarsState();

  @override
  List<Object?> get props => [];
}

final class MyCarsInitial extends MyCarsState {}

// --- Main Cars List States ---
final class MyCarsLoading extends MyCarsState {}

final class MyCarsLoaded extends MyCarsState {
  final List<MyCarModel> cars;
  const MyCarsLoaded(this.cars);

  @override
  List<Object?> get props => [cars];
}

final class MyCarsError extends MyCarsState {
  final String message;
  const MyCarsError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Action States (Add, Update, Delete) ---
final class MyCarsActionLoading extends MyCarsState {}

sealed class MyCarsActionSuccess extends MyCarsState {
  final String message;
  const MyCarsActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class MyCarsActionAdding extends MyCarsActionSuccess {
  const MyCarsActionAdding(super.message);
}

final class MyCarsActionUpdating extends MyCarsActionSuccess {
  const MyCarsActionUpdating(super.message);
}

final class MyCarsActionDeleting extends MyCarsActionSuccess {
  const MyCarsActionDeleting(super.message);
}

final class MyCarsActionError extends MyCarsState {
  final String message;
  const MyCarsActionError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Brand Makes Catalog States ---
final class BrandsLoading extends MyCarsState {}

final class BrandsLoaded extends MyCarsState {
  final List<VehicleBrandModel> makes;
  const BrandsLoaded(this.makes);

  @override
  List<Object?> get props => [makes];
}

final class BrandsError extends MyCarsState {
  final String message;
  const BrandsError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Car Models Catalog States ---
final class ModelsLoading extends MyCarsState {}

final class ModelsLoaded extends MyCarsState {
  final List<VehicleModelModel> models;
  const ModelsLoaded(this.models);

  @override
  List<Object?> get props => [models];
}

final class ModelsError extends MyCarsState {
  final String message;
  const ModelsError(this.message);

  @override
  List<Object?> get props => [message];
}
