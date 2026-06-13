import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/faqs_repository.dart';
import 'faqs_state.dart';

class FaqsCubit extends Cubit<FaqsState> {
  final FaqsRepository _repository;

  FaqsCubit(this._repository) : super(FaqsInitial());

  Future<void> fetchFaqs() async {
    emit(FaqsLoading());
    final result = await _repository.getFaqs();
    result.fold(
      (failure) => emit(FaqsFailure(failure.message)),
      (faqs) => emit(FaqsSuccess(faqs)),
    );
  }
}
