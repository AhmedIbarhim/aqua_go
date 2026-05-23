import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:aqua_go/core/helpers/connectivity_helper.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  late final StreamSubscription<bool> _subscription;

  ConnectivityCubit()
      : super(ConnectivityInitial(isConnected: ConnectivityHelper().isConnected)) {
    _subscription = ConnectivityHelper().connectivityStream.listen((isConnected) {
      emit(ConnectivityChanged(isConnected: isConnected));
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
