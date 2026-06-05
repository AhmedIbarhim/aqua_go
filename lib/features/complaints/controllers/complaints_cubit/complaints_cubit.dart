import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/complaints_repository.dart';
import 'complaints_state.dart';

class ComplaintsCubit extends Cubit<ComplaintsState> {
  final ComplaintsRepository _repository;

  ComplaintsCubit(this._repository) : super(ComplaintsInitial());

  Future<void> fetchComplaints() async {
    emit(ComplaintsLoading());
    final result = await _repository.getComplaints();
    result.fold(
      (failure) => emit(ComplaintsFailure(failure.message)),
      (complaints) => emit(ComplaintsSuccess(complaints)),
    );
  }

  Future<void> submitComplaint({
    required String bookingId,
    required String category,
    required String description,
    String? desiredOutcome,
    String? preferredContactChannel,
    List<File> photos = const [],
  }) async {
    emit(ComplaintSubmitLoading());
    final result = await _repository.raiseComplaint(
      bookingId: bookingId,
      category: category,
      description: description,
      desiredOutcome: desiredOutcome,
      preferredContactChannel: preferredContactChannel,
      photos: photos,
    );
    result.fold(
      (failure) => emit(ComplaintSubmitFailure(failure.message)),
      (complaint) => emit(ComplaintSubmitSuccess(complaint)),
    );
  }
}
