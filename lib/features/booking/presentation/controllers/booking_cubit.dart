import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../data/repos/booking_repo.dart';
import '../widgets/payment_method_selection.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepo _bookingRepo;

  BookingCubit({required BookingRepo bookingRepo})
    : _bookingRepo = bookingRepo,
      super(const BookingState());

  void selectAddress(AddressModel address) {
    emit(state.copyWith(selectedAddress: address));
  }

  void selectCar(MyCarModel car) {
    emit(state.copyWith(selectedCar: car));
  }

  void toggleService(int serviceIndex) {
    final updatedServices = Set<int>.from(state.selectedServiceIndices);
    if (updatedServices.contains(serviceIndex)) {
      updatedServices.remove(serviceIndex);
    } else {
      updatedServices.add(serviceIndex);
    }
    emit(state.copyWith(selectedServiceIndices: updatedServices));
  }

  void updateDateTime(DateTime? date, String? time) {
    emit(state.copyWith(selectedDate: date, selectedTime: time));
  }

  void updateNotes(Set<String> notes) {
    emit(state.copyWith(bikerNotes: notes));
  }

  void updatePaymentMethod(PaymentMethod method) {
    emit(state.copyWith(paymentMethod: method));
  }

  Future<void> submitBooking() async {
    if (state.selectedAddress == null ||
        state.selectedCar == null ||
        state.selectedDate == null ||
        state.selectedTime == null) {
      emit(
        state.copyWith(
          status: BookingStatus.failure,
          errorMessage: 'يرجى إكمال جميع بيانات الحجز المطلوبة',
        ),
      );
      return;
    }

    emit(state.copyWith(status: BookingStatus.loading));

    final result = await _bookingRepo.createBooking();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BookingStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: BookingStatus.success)),
    );
  }
}
