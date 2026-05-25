import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repos/my_bookings_repository.dart';
import 'my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  final MyBookingsRepository _repository;
  bool _isLoadingMore = false;

  MyBookingsCubit(this._repository) : super(MyBookingsInitial());

  Future<void> fetchBookings({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(MyBookingsLoading());
    }

    final result = await _repository.getBookings(limit: 20);

    result.fold(
      (failure) => emit(MyBookingsFailure(failure.message)),
      (response) {
        emit(
          MyBookingsSuccess(
            bookings: response.items,
            nextCursor: response.nextCursor,
            hasReachedMax: response.nextCursor == null || response.nextCursor!.isEmpty,
          ),
        );
      },
    );
  }

  Future<void> loadMoreBookings() async {
    final currentState = state;
    if (currentState is! MyBookingsSuccess ||
        currentState.hasReachedMax ||
        _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;

    final result = await _repository.getBookings(
      limit: 20,
      cursor: currentState.nextCursor,
    );

    result.fold(
      (failure) {
        _isLoadingMore = false;
      },
      (response) {
        _isLoadingMore = false;
        emit(
          currentState.copyWith(
            bookings: [...currentState.bookings, ...response.items],
            nextCursor: response.nextCursor,
            hasReachedMax: response.nextCursor == null || response.nextCursor!.isEmpty,
          ),
        );
      },
    );
  }
}
