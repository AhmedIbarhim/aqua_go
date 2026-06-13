import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/my_bookings_repository.dart';
import 'my_booking_details_state.dart';

class MyBookingDetailsCubit extends Cubit<MyBookingDetailsState> {
  final MyBookingsRepository _repository;

  MyBookingDetailsCubit(this._repository) : super(MyBookingDetailsInitial());

  Future<void> fetchBookingDetails(String id) async {
    emit(MyBookingDetailsLoading());

    final result = await _repository.getBookingDetails(id);

    result.fold(
      (failure) => emit(MyBookingDetailsFailure(failure.message)),
      (booking) => emit(MyBookingDetailsSuccess(booking)),
    );
  }
}
