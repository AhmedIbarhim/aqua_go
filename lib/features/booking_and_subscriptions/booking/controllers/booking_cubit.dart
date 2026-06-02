import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_go/core/config/local_storage/shared_prefs.dart';
import 'package:aqua_go/core/constants.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:intl/intl.dart';
import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import '../data/models/booking_request_model.dart';
import '../data/models/add_on_model.dart';
import '../data/models/biker_note.dart';
import '../data/models/quote_model.dart';
import '../data/repos/booking_repo.dart';
import '../../../../core/enums/payment_method_enum.dart';
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
    final defaultDate = state.selectedDate ?? DateTime.now();
    emit(
      state.copyWith(
        selectedAddress: address,
        selectedDate: defaultDate,
        clearError: true,
      ),
    );
    if (state.selectedService != null) {
      fetchAvailability(targetDate: defaultDate);
    }
  }

  void selectCar(MyCarModel car) {
    emit(state.copyWith(selectedCar: car, clearError: true));
  }

  void toggleService(int serviceIndex) {
    final updatedServices = Set<int>.from(state.selectedServiceIndices);
    if (updatedServices.contains(serviceIndex)) {
      updatedServices.remove(serviceIndex);
    } else {
      updatedServices.add(serviceIndex);
    }
    emit(
      state.copyWith(selectedServiceIndices: updatedServices, clearError: true),
    );
  }

  void updateDateTime(DateTime? date, String? time) {
    final dateChanged = date != state.selectedDate;
    emit(
      state.copyWith(
        selectedDate: date,
        selectedTime: dateChanged ? null : time,
        clearError: true,
      ),
    );
    if (dateChanged && date != null) {
      fetchAvailability(targetDate: date);
    }
  }

  void updateNotes(Set<String> notes) {
    emit(state.copyWith(bikerNotes: notes, clearError: true));
  }

  void updateSpecialNoteText(String text) {
    emit(state.copyWith(specialNoteText: text, clearError: true));
  }

  void updatePaymentMethod(PaymentMethod method) {
    emit(state.copyWith(paymentMethod: method, clearError: true));
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
      (data) {
        final isAvailable = data['inServiceArea'] as bool? ?? false;
        final zoneId = data['zoneId'] as String?;
        if (isAvailable && state.selectedAddress != null) {
          emit(
            state.copyWith(
              status: BookingStatus.initial,
              selectedAddress: state.selectedAddress!.copyWith(zoneId: zoneId),
            ),
          );
        } else {
          emit(state.copyWith(status: BookingStatus.initial));
        }
        return isAvailable;
      },
    );
  }

  Future<void> fetchAvailability({DateTime? targetDate}) async {
    final date = targetDate ?? state.selectedDate ?? DateTime.now();
    final address = state.selectedAddress;
    final service = state.selectedService;

    if (address == null || service == null) {
      return;
    }

    // Format date as YYYY-MM-DD
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // Get zoneId
    String? zoneId = address.zoneId;
    if (zoneId == null || zoneId.isEmpty) {
      emit(state.copyWith(isAvailabilityLoading: true));
      final result = await _bookingRepo.checkZoneAvailability(
        address.lat,
        address.lng,
      );
      final fetchedZoneId = result.fold(
        (failure) => null,
        (data) => data['zoneId'] as String?,
      );
      if (fetchedZoneId == null) {
        emit(
          state.copyWith(
            isAvailabilityLoading: false,
            errorMessage: 'Failed to retrieve service zone details',
          ),
        );
        return;
      }
      zoneId = fetchedZoneId;
      // Update selectedAddress with the zoneId
      emit(state.copyWith(selectedAddress: address.copyWith(zoneId: zoneId)));
    }

    emit(state.copyWith(isAvailabilityLoading: true));

    final result = await _bookingRepo.getAvailability(
      zoneId: zoneId,
      date: dateStr,
      packageId: service.id,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isAvailabilityLoading: false,
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            isAvailabilityLoading: false,
            availabilitySlots: response.slots,
          ),
        );
      },
    );
  }

  Future<QuoteModel?> fetchQuote({String? promoCode}) async {
    if (state.selectedService == null || state.selectedAddress == null) {
      return null;
    }

    emit(state.copyWith(status: BookingStatus.loading));

    final result = await _bookingRepo.getQuote(
      packageId: state.selectedService!.id,
      lat: state.selectedAddress!.lat,
      lng: state.selectedAddress!.lng,
      promoCode: promoCode,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: BookingStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return null;
      },
      (quote) {
        emit(state.copyWith(status: BookingStatus.initial, quote: quote));
        return quote;
      },
    );
  }

  Future<void> submitBooking({String? promoCode}) async {
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

    QuoteModel? quote = state.quote;
    if (quote == null) {
      final quoteResult = await _bookingRepo.getQuote(
        packageId: state.selectedService!.id,
        lat: state.selectedAddress!.lat,
        lng: state.selectedAddress!.lng,
        promoCode: promoCode,
      );

      final hasError = quoteResult.fold(
        (failure) {
          emit(
            state.copyWith(
              status: BookingStatus.failure,
              errorMessage: failure.message,
            ),
          );
          return true;
        },
        (fetchedQuote) {
          quote = fetchedQuote;
          emit(state.copyWith(quote: fetchedQuote));
          return false;
        },
      );

      if (hasError || quote == null) return;
    }

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

    final booking = BookingRequestModel(
      service: state.selectedService,
      car: state.selectedCar,
      address: state.selectedAddress,
      date: state.selectedDate,
      time: state.selectedTime,
      additionalServices: addonsList,
      workerNotes: notesList,
      paymentMethod: state.paymentMethod,
      quote: quote,
    );

    final result = await _bookingRepo.createBooking(booking);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BookingStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (bookingResponse) => emit(
        state.copyWith(
          status: BookingStatus.success,
          createdBooking: bookingResponse,
        ),
      ),
    );
  }
}
