part of 'addresses_cubit.dart';

sealed class AddressesState extends Equatable {
  const AddressesState();

  @override
  List<Object?> get props => [];
}

final class AddressesInitial extends AddressesState {}

// --- Main Addresses List States ---
final class AddressesLoading extends AddressesState {}

final class AddressesLoaded extends AddressesState {
  final List<AddressModel> addresses;
  const AddressesLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

final class AddressesError extends AddressesState {
  final String message;
  const AddressesError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Action States (Add, Update, Delete) ---
final class AddressesActionLoading extends AddressesState {}

final class AddressesActionSuccess extends AddressesState {}

final class AddressesActionError extends AddressesState {
  final String message;
  const AddressesActionError(this.message);

  @override
  List<Object?> get props => [message];
}
