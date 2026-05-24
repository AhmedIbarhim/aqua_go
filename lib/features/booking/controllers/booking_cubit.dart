import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../address/data/models/address_model.dart';
import '../../my_cars/data/models/my_car_model.dart';
import '../../home/data/models/service_model.dart';
import '../data/models/booking_model.dart';
import '../data/models/add_on_model.dart';
import '../data/models/biker_note.dart';
import '../data/repos/booking_repo.dart';
import '../../../core/enums/payment_method_enum.dart';
import '../presentation/widgets/add_ons_grid.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepo _bookingRepo;

  BookingCubit({required BookingRepo bookingRepo})
    : _bookingRepo = bookingRepo,
      super(const BookingState());

  void initBooking(ServiceModel? service) {
    emit(BookingState(status: BookingStatus.initial, selectedService: service));
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

  void updateSpecialNoteText(String text) {
    emit(state.copyWith(specialNoteText: text));
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

    final List<AddOnModel> addonsList = [];
    for (final idx in state.selectedServiceIndices) {
      if (idx < AddOnsGrid.additionalServices.length) {
        final item = AddOnsGrid.additionalServices[idx];
        addonsList.add(
          AddOnModel(
            id: item['id'] ?? idx.toString(),
            name: item['title'] ?? '',
            price: double.tryParse(item['price'] ?? '0.00') ?? 0.0,
            image: item['icon'] ?? '',
          ),
        );
      }
    }

    final List<String> notesList = [];
    final lang = CacheClient.getString(kLanguage);
    final isArabic = lang.isEmpty || lang == 'ar';

    for (final noteKey in state.bikerNotes) {
      if (noteKey == LocaleKeys.bookings_special_note) {
        if (state.specialNoteText.trim().isNotEmpty) {
          notesList.add(state.specialNoteText.trim());
        }
      } else {
        final enumVal = BikerNote.fromKey(noteKey);
        if (enumVal != null) {
          notesList.add(enumVal.getValue(isArabic));
        }
      }
    }

    final booking = BookingModel(
      service: state.selectedService,
      car: state.selectedCar,
      address: state.selectedAddress,
      date: state.selectedDate,
      time: state.selectedTime,
      additionalServices: addonsList,
      bikerNotes: notesList,
      paymentMethod: state.paymentMethod,
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
