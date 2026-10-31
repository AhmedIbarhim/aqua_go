import 'package:flutter_bloc/flutter_bloc.dart';

/// A request can outlive its screen, and bloc throws on an emit after close.
mixin ClosedSafeEmit<S> on Cubit<S> {
  @override
  void emit(S state) {
    if (!isClosed) super.emit(state);
  }
}
