import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../controllers/booking_state.dart';

/// Mirrors one cubit's loading status onto the app's loading overlay. The
/// overlay is a shared counter, so this pairs every show with exactly one hide
/// and several cubits can drive it side by side.
BlocListener<C, S> bookingLoadingOverlayListener<
  C extends StateStreamable<S>,
  S
>(BookingStatus Function(S state) statusOf) {
  bool isLoading(S state) => statusOf(state) == BookingStatus.loading;

  return BlocListener<C, S>(
    listenWhen: (previous, current) =>
        isLoading(previous) != isLoading(current),
    listener: (BuildContext context, S state) {
      if (isLoading(state)) {
        context.showLoadingOverlay();
      } else {
        context.hideLoadingOverlay();
      }
    },
  );
}
