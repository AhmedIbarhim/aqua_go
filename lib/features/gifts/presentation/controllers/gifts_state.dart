import 'package:equatable/equatable.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/received_gift_model.dart';

abstract class GiftsState extends Equatable {
  const GiftsState();

  @override
  List<Object?> get props => [];
}

class GiftsInitial extends GiftsState {}

class GiftsLoading extends GiftsState {}

class GiftsSuccess extends GiftsState {
  final List<GiftModel> sentGifts;
  final List<ReceivedGiftModel> receivedGifts;
  final String? nextCursorSent;
  final String? nextCursorReceived;
  final bool hasReachedMaxSent;
  final bool hasReachedMaxReceived;

  const GiftsSuccess({
    required this.sentGifts,
    required this.receivedGifts,
    this.nextCursorSent,
    this.nextCursorReceived,
    required this.hasReachedMaxSent,
    required this.hasReachedMaxReceived,
  });

  GiftsSuccess copyWith({
    List<GiftModel>? sentGifts,
    List<ReceivedGiftModel>? receivedGifts,
    String? nextCursorSent,
    String? nextCursorReceived,
    bool? hasReachedMaxSent,
    bool? hasReachedMaxReceived,
  }) {
    return GiftsSuccess(
      sentGifts: sentGifts ?? this.sentGifts,
      receivedGifts: receivedGifts ?? this.receivedGifts,
      nextCursorSent: nextCursorSent ?? this.nextCursorSent,
      nextCursorReceived: nextCursorReceived ?? this.nextCursorReceived,
      hasReachedMaxSent: hasReachedMaxSent ?? this.hasReachedMaxSent,
      hasReachedMaxReceived:
          hasReachedMaxReceived ?? this.hasReachedMaxReceived,
    );
  }

  @override
  List<Object?> get props => [
    sentGifts,
    receivedGifts,
    nextCursorSent,
    nextCursorReceived,
    hasReachedMaxSent,
    hasReachedMaxReceived,
  ];
}

class GiftsFailure extends GiftsState {
  final String errMessage;

  const GiftsFailure(this.errMessage);

  @override
  List<Object?> get props => [errMessage];
}
