import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/gifts_repository.dart';
import 'gifts_state.dart';

class GiftsCubit extends Cubit<GiftsState> {
  final GiftsRepository _repository;
  bool _isLoadingMore = false;

  GiftsCubit(this._repository) : super(GiftsInitial());

  Future<void> fetchGifts({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(GiftsLoading());
    }

    final result = await _repository.getGifts(limit: 20);

    result.fold(
      (failure) => emit(GiftsFailure(failure.message)),
      (response) {
        emit(
          GiftsSuccess(
            gifts: response.items,
            nextCursor: response.nextCursor,
            hasReachedMax: response.nextCursor == null || response.nextCursor!.isEmpty,
          ),
        );
      },
    );
  }

  Future<void> loadMoreGifts() async {
    final currentState = state;
    if (currentState is! GiftsSuccess ||
        currentState.hasReachedMax ||
        _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;

    final result = await _repository.getGifts(
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
            gifts: [...currentState.gifts, ...response.items],
            nextCursor: response.nextCursor,
            hasReachedMax: response.nextCursor == null || response.nextCursor!.isEmpty,
          ),
        );
      },
    );
  }

  Future<bool> redeemGift(String code) async {
    final result = await _repository.redeemGift(code);
    return result.fold(
      (failure) => false,
      (success) {
        fetchGifts(isRefresh: true);
        return true;
      },
    );
  }
}
