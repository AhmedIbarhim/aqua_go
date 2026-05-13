part of 'my_cars_cubit.dart';

sealed class MyCarsState extends Equatable {
  const MyCarsState();

  @override
  List<Object?> get props => [];
}

final class MyCarsInitial extends MyCarsState {}

final class MyCarsLoaded extends MyCarsState {
  final List<MyCarModel> cars;
  const MyCarsLoaded(this.cars);

  @override
  List<Object?> get props => [cars];
}
