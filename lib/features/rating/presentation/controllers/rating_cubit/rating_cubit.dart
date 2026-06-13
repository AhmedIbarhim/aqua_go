import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/rating_repository.dart';
import 'rating_state.dart';

class RatingCubit extends Cubit<RatingState> {
  final RatingRepository _repository;

  RatingCubit(this._repository) : super(RatingInitial());

  Future<void> submitRating({
    required String bookingId,
    required int score,
    String? comment,
    List<String>? reasons,
  }) async {
    emit(RatingSubmitLoading());
    final result = await _repository.rateBooking(
      bookingId: bookingId,
      score: score,
      comment: comment,
      reasons: reasons,
    );
    result.fold(
      (failure) => emit(RatingSubmitFailure(failure.message)),
      (ratingModel) => emit(RatingSubmitSuccess(ratingModel)),
    );
  }
}
