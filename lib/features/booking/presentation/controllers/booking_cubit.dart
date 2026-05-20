import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/additional_service_model.dart';
import '../../data/repos/booking_repo.dart';
import '../widgets/payment_method_selection.dart';
import '../widgets/additional_services_grid.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepo _bookingRepo;

  BookingCubit({required BookingRepo bookingRepo})
    : _bookingRepo = bookingRepo,
      super(const BookingState());

  void initBooking(ServiceModel? service) {
    emit(BookingState(
      status: BookingStatus.initial,
      selectedService: service,
    ));
  }

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

  Future<bool> checkZone(double lat, double lng) async {
    emit(state.copyWith(status: BookingStatus.loading));
    final result = await _bookingRepo.checkZoneAvailability(lat, lng);
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: BookingStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
      (isAvailable) {
        emit(state.copyWith(status: BookingStatus.initial));
        return isAvailable;
      },
    );
  }

  Future<void> submitBooking() async {
    if (state.selectedAddress == null ||
        state.selectedCar == null ||
        state.selectedDate == null ||
        state.selectedTime == null ||
        state.selectedService == null) {
      emit(
        state.copyWith(
          status: BookingStatus.failure,
          errorMessage: 'يرجى إكمال جميع بيانات الحجز المطلوبة',
        ),
      );
      return;
    }

    emit(state.copyWith(status: BookingStatus.loading));

    final List<AdditionalServiceModel> addonsList = [];
    for (final idx in state.selectedServiceIndices) {
      if (idx < AdditionalServicesGrid.additionalServices.length) {
        final item = AdditionalServicesGrid.additionalServices[idx];
        addonsList.add(AdditionalServiceModel(
          id: item['id'] ?? idx.toString(),
          name: item['title'] ?? '',
          price: double.tryParse(item['price'] ?? '0.00') ?? 0.0,
          image: item['icon'] ?? '',
        ));
      }
    }

    final booking = BookingModel(
      service: state.selectedService,
      car: state.selectedCar,
      address: state.selectedAddress,
      date: state.selectedDate,
      time: state.selectedTime,
      additionalServices: addonsList,
      notes: state.bikerNotes.join(', '),
      paymentMethod: state.paymentMethod?.name,
    );

    final result = await _bookingRepo.createBooking(booking);
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
