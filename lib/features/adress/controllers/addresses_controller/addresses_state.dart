part of 'addresses_cubit.dart';

sealed class AddressesState extends Equatable {
  const AddressesState();

  @override
  List<Object?> get props => [];
}

final class AddressesInitial extends AddressesState {}

final class AddressesLoaded extends AddressesState {
  final List<AddressModel> addresses;
  const AddressesLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}
