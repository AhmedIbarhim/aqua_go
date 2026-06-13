import 'package:aqua_go/features/rating/data/models/rating_model.dart';

abstract class RatingState {}

class RatingInitial extends RatingState {}

class RatingSubmitLoading extends RatingState {}

class RatingSubmitSuccess extends RatingState {
  final RatingModel ratingModel;
  RatingSubmitSuccess(this.ratingModel);
}

class RatingSubmitFailure extends RatingState {
  final String message;
  RatingSubmitFailure(this.message);
}
