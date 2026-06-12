import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../address/data/models/address_model.dart';
import '../../my_cars/data/models/my_car_model.dart';
import '../../home/data/models/service_model.dart';
import '../domain/configs/booking_flow_config.dart';
import '../data/models/quote_model.dart';
import '../data/repos/booking_repository.dart';
import '../../../core/enums/payment_method_enum.dart';
import '../domain/strategies/booking_submit_strategy.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _bookingRepo;
  final BookingFlowConfig _flowConfig;
  final BookingSubmitStrategy _submitStrategy;

  BookingCubit({
    required BookingRepository bookingRepo,
    BookingFlowConfig flowConfig = BookingFlowConfig.normal,
    required BookingSubmitStrategy submitStrategy,
  }) : _bookingRepo = bookingRepo,
       _flowConfig = flowConfig,
       _submitStrategy = submitStrategy,
       super(BookingState(flowConfig: flowConfig));

  void initBooking(
    ServiceModel? service, {
    MyCarModel? existingCar,
    AddressModel? existingAddress,
  }) {
    emit(
      BookingState(
        status: BookingStatus.initial,
        selectedService: service,
        selectedCar: existingCar,
        selectedAddress: existingAddress,
        flowConfig: _flowConfig,
      ),
    );
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
    // // Validate based on flow config
    // if (state.selectedAddress == null ||
    //     state.selectedCar == null ||
    //     state.selectedDate == null ||
    //     state.selectedTime == null) {
    //   emit(
    //     state.copyWith(
    //       status: BookingStatus.failure,
    //       errorMessage: 'يرجى إكمال جميع بيانات الحجز المطلوبة',
    //     ),
    //   );
    //   return;
    // }

    // // Only validate service for flows that require it
    // if (!_flowConfig.isReschedule && state.selectedService == null) {
    //   emit(
    //     state.copyWith(
    //       status: BookingStatus.failure,
    //       errorMessage: 'يرجى إكمال جميع بيانات الحجز المطلوبة',
    //     ),
    //   );
    //   return;
    // }

    // emit(state.copyWith(status: BookingStatus.loading));

    // // Only fetch quote for flows that require it
    // if (_flowConfig.requiresQuote && state.quote == null) {
    //   final quoteResult = await _bookingRepo.getQuote(
    //     packageId: state.selectedService!.id,
    //     lat: state.selectedAddress!.lat,
    //     lng: state.selectedAddress!.lng,
    //     promoCode: promoCode,
    //   );

    //   final hasError = quoteResult.fold(
    //     (failure) {
    //       emit(
    //         state.copyWith(
    //           status: BookingStatus.failure,
    //           errorMessage: failure.message,
    //         ),
    //       );
    //       return true;
    //     },
    //     (fetchedQuote) {
    //       emit(state.copyWith(quote: fetchedQuote));
    //       return false;
    //     },
    //   );

    //   if (hasError) return;
    // }

    // Delegate to the strategy
    final result = await _submitStrategy.submit(
      repo: _bookingRepo,
      state: state,
    );

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
