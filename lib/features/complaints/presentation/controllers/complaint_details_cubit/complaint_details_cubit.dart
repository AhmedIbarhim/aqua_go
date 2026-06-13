import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/complaints_repository.dart';
import '../../../../my_bookings/data/repos/my_bookings_repository.dart';
import 'complaint_details_state.dart';

class ComplaintDetailsCubit extends Cubit<ComplaintDetailsState> {
  final ComplaintsRepository _complaintsRepository;
  final MyBookingsRepository _bookingsRepository;

  ComplaintDetailsCubit(this._complaintsRepository, this._bookingsRepository)
    : super(ComplaintDetailsInitial());

  Future<void> fetchComplaintDetails(String id) async {
    emit(ComplaintDetailsLoading());

    final complaintResult = await _complaintsRepository.getComplaintDetail(id);

    await complaintResult.fold(
      (failure) async => emit(ComplaintDetailsFailure(failure.message)),
      (complaint) async {
        if (complaint.bookingId.isNotEmpty) {
          final bookingResult = await _bookingsRepository.getBookingDetails(
            complaint.bookingId,
          );
          bookingResult.fold(
            (failure) => emit(ComplaintDetailsSuccess(complaint, null)),
            (booking) => emit(ComplaintDetailsSuccess(complaint, booking)),
          );
        } else {
          emit(ComplaintDetailsSuccess(complaint, null));
        }
      },
    );
  }
}
