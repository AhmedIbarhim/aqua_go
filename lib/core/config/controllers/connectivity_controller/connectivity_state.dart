part of 'connectivity_cubit.dart';

abstract class ConnectivityState extends Equatable {
  final bool isConnected;
  const ConnectivityState({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}

class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial({required super.isConnected});
}

class ConnectivityChanged extends ConnectivityState {
  const ConnectivityChanged({required super.isConnected});
}
