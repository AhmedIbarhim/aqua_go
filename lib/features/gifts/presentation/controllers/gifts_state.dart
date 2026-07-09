import 'package:equatable/equatable.dart';
import '../../data/models/gift_model.dart';

abstract class GiftsState extends Equatable {
  const GiftsState();

  @override
  List<Object?> get props => [];
}

class GiftsInitial extends GiftsState {}

class GiftsLoading extends GiftsState {}

class GiftsSuccess extends GiftsState {
  final List<GiftModel> gifts;
  final String? nextCursor;
  final bool hasReachedMax;

  const GiftsSuccess({
    required this.gifts,
    this.nextCursor,
    required this.hasReachedMax,
  });

  GiftsSuccess copyWith({
    List<GiftModel>? gifts,
    String? nextCursor,
    bool? hasReachedMax,
  }) {
    return GiftsSuccess(
      gifts: gifts ?? this.gifts,
      nextCursor: nextCursor ?? this.nextCursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [gifts, nextCursor, hasReachedMax];
}

class GiftsFailure extends GiftsState {
  final String errMessage;

  const GiftsFailure(this.errMessage);

  @override
  List<Object?> get props => [errMessage];
}
