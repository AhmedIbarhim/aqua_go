import '../../data/models/Faq_model.dart';

abstract class FaqsState {}

class FaqsInitial extends FaqsState {}

class FaqsLoading extends FaqsState {}

class FaqsSuccess extends FaqsState {
  final List<FaqModel> faqs;
  FaqsSuccess(this.faqs);
}

class FaqsFailure extends FaqsState {
  final String message;
  FaqsFailure(this.message);
}
