import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/received_gift_model.dart';
import '../../data/repos/gifts_repository.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/gifts_list_response_model.dart';
import '../../data/models/received_gifts_list_response_model.dart';
import 'gifts_state.dart';

class GiftsCubit extends Cubit<GiftsState> {
  final GiftsRepository _repository;
  bool _isLoadingMore = false;

  GiftsCubit(this._repository) : super(GiftsInitial());

  Future<void> fetchGifts({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(GiftsLoading());
    }

    final sentFuture = _repository.getGifts(limit: 20);
    final receivedFuture = _repository.getReceivedGifts(limit: 20);

    final results = await Future.wait([sentFuture, receivedFuture]);
    final sentResult = results[0];
    final receivedResult = results[1];

    if (sentResult.isLeft() && receivedResult.isLeft()) {
      final failure = sentResult.fold((f) => f, (_) => null)!;
      emit(GiftsFailure(failure.message));
      return;
    }

    final sentList = sentResult.fold(
      (failure) => <GiftModel>[],
      (response) => (response as GiftsListResponseModel).items,
    );
    final nextCursorSent = sentResult.fold(
      (failure) => null,
      (response) => (response as GiftsListResponseModel).nextCursor,
    );

    final receivedList = receivedResult.fold(
      (failure) => <ReceivedGiftModel>[],
      (response) => (response as ReceivedGiftsListResponseModel).items,
    );
    final nextCursorReceived = receivedResult.fold(
      (failure) => null,
      (response) => (response as ReceivedGiftsListResponseModel).nextCursor,
    );

    emit(
      GiftsSuccess(
        sentGifts: sentList,
        receivedGifts: receivedList,
        nextCursorSent: nextCursorSent,
        nextCursorReceived: nextCursorReceived,
        hasReachedMaxSent: nextCursorSent == null || nextCursorSent.isEmpty,
        hasReachedMaxReceived:
            nextCursorReceived == null || nextCursorReceived.isEmpty,
      ),
    );
  }

  Future<void> loadMoreGifts({required int tabIndex}) async {
    final currentState = state;
    if (currentState is! GiftsSuccess || _isLoadingMore) {
      return;
    }

    if (tabIndex == 0) {
      if (currentState.hasReachedMaxSent) return;
      _isLoadingMore = true;

      final result = await _repository.getGifts(
        limit: 20,
        cursor: currentState.nextCursorSent,
      );

      result.fold(
        (failure) {
          _isLoadingMore = false;
        },
        (response) {
          _isLoadingMore = false;
          emit(
            currentState.copyWith(
              sentGifts: [...currentState.sentGifts, ...response.items],
              nextCursorSent: response.nextCursor,
              hasReachedMaxSent:
                  response.nextCursor == null || response.nextCursor!.isEmpty,
            ),
          );
        },
      );
    } else {
      if (currentState.hasReachedMaxReceived) return;
      _isLoadingMore = true;

      final result = await _repository.getReceivedGifts(
        limit: 20,
        cursor: currentState.nextCursorReceived,
      );

      result.fold(
        (failure) {
          _isLoadingMore = false;
        },
        (response) {
          _isLoadingMore = false;
          emit(
            currentState.copyWith(
              receivedGifts: [...currentState.receivedGifts, ...response.items],
              nextCursorReceived: response.nextCursor,
              hasReachedMaxReceived:
                  response.nextCursor == null || response.nextCursor!.isEmpty,
            ),
          );
        },
      );
    }
  }

  Future<bool> redeemGift(String code) async {
    final result = await _repository.redeemGift(code);
    return result.fold((failure) => false, (success) {
      fetchGifts(isRefresh: true);
      return true;
    });
  }
}
