import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aqua_go/features/my_bookings/data/repos/my_bookings_repository.dart';
import 'package:aqua_go/features/rating/data/dismissed_ratings_store.dart';
import 'pending_ratings_state.dart';

/// Drives the AQG-160 home rating popup: fetches completed-but-unrated bookings
/// inside the live 7-day window and filters out ids the user locally dismissed.
/// A failed fetch emits [PendingRatingsFailure] silently — the home screen must
/// never block rendering or surface an error for this background nudge.
class PendingRatingsCubit extends Cubit<PendingRatingsState> {
  final MyBookingsRepository _repository;

  PendingRatingsCubit(this._repository) : super(PendingRatingsInitial());

  Future<void> fetchPendingRatings() async {
    emit(PendingRatingsLoading());

    final result = await _repository.getPendingRatings();

    result.fold(
      (failure) => emit(PendingRatingsFailure(failure.message)),
      (bookings) {
        final pending = bookings
            .where((b) =>
                (b.id ?? '').isNotEmpty &&
                !DismissedRatingsStore.isDismissed(b.id!))
            .toList();
        emit(PendingRatingsLoaded(pending));
      },
    );
  }
}
