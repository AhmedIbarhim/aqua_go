import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../domain/configs/booking_flow_config.dart';
import '../../data/models/quote_model.dart';
import '../../data/repos/booking_repository.dart';
import '../../../../core/enums/payment_method_enum.dart';
import '../../domain/strategies/booking_submit_strategy.dart';
import 'booking_state.dart';
import 'package:aqua_go/features/home/data/models/add_on_model.dart';
import 'package:aqua_go/features/subscriptions/data/repos/subscriptions_repository.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_wash.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_included_allowance.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _bookingRepo;
  final SubscriptionsRepository _subscriptionsRepo;
  final BookingFlowConfig _flowConfig;
  final BookingSubmitStrategy _submitStrategy;

  BookingCubit({
    required BookingRepository bookingRepo,
    required SubscriptionsRepository subscriptionsRepo,
    BookingFlowConfig flowConfig = BookingFlowConfig.normal,
    required BookingSubmitStrategy submitStrategy,
  }) : _bookingRepo = bookingRepo,
       _subscriptionsRepo = subscriptionsRepo,
       _flowConfig = flowConfig,
       _submitStrategy = submitStrategy,
       super(BookingState(flowConfig: flowConfig));

  void initBooking(
    ServiceModel? service, {
    MyCarModel? existingCar,
    AddressModel? existingAddress,
    String? subscriptionId,
    String? washId,
  }) {
    emit(
      BookingState(
        status: BookingStatus.initial,
        selectedService: service,
        selectedCar: existingCar,
        selectedAddress: existingAddress,
        flowConfig: _flowConfig,
        subscriptionId: subscriptionId,
        washId: washId,
      ),
    );

    if (subscriptionId != null) {
      fetchSubscriptionDetails(subscriptionId);
    }
  }

  Future<void> fetchSubscriptionDetails(String subscriptionId) async {
    emit(state.copyWith(status: BookingStatus.loading));
    final result = await _subscriptionsRepo.fetchSubscriptionDetail(
      subscriptionId: subscriptionId,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: BookingStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (detailedPackage) {
        SubscriptionWash? wash;
        if (state.washId != null) {
          for (final w in detailedPackage.washes) {
            if (w.washId == state.washId) {
              wash = w;
              break;
            }
          }
        }
        if (wash == null) {
          for (final w in detailedPackage.washes) {
            if (w.canSchedule) {
              wash = w;
              break;
            }
          }
        }

        if (wash == null) {
          emit(
            state.copyWith(
              status: BookingStatus.failure,
              errorMessage: 'No washes available in this subscription',
            ),
          );
          return;
        }

        // --- Build unified addons list from PackageInfo ---
        // 1) Included addons — come with price data for when free qty runs out
        final includedAddons = detailedPackage.packageInfo.includedAddons.map((
          a,
        ) {
          final allowance = detailedPackage.includedAllowances.firstWhere(
            (allow) => allow.addonId == a.id,
            orElse: () => SubscriptionIncludedAllowance(
              addonId: a.id ?? '',
              totalQty: a.freeQty ?? 0,
              consumedQty: 0,
              remainingQty: a.freeQty ?? 0,
            ),
          );

          return AddOnModel(
            id: a.id,
            nameAr: a.nameAr,
            nameEn: a.nameEn,
            priceMinor: allowance.remainingQty > 0 ? 0 : a.priceMinor,
            currency: a.currency,
            imageUrl: a.imageUrl,
            freeQty: allowance.remainingQty,
            maxQtyPerWash: a.maxQtyPerWash ?? allowance.totalQty,
            qty: allowance.consumedQty,
            kind: 'included',
          );
        }).toList();

        // 2) Optional addons — always paid. Prefer packageInfo, fall back to wash.
        final rawOptional =
            detailedPackage.packageInfo.optionalAddons.isNotEmpty
            ? detailedPackage.packageInfo.optionalAddons
            : wash.availableOptionalAddons;
        final optionalAddons = rawOptional
            .map(
              (a) => AddOnModel(
                id: a.id,
                nameAr: a.nameAr,
                nameEn: a.nameEn,
                priceMinor: a.priceMinor,
                currency: a.currency,
                imageUrl: a.imageUrl,
                kind: 'optional',
              ),
            )
            .toList();

        final allAddons = [...includedAddons, ...optionalAddons];

        final includedIds = includedAddons
            .map((a) => a.id)
            .whereType<String>()
            .toSet();
        final optionalIds = optionalAddons
            .map((a) => a.id)
            .whereType<String>()
            .toSet();

        final service = ServiceModel(
          id: detailedPackage.packageId,
          code: '',
          rawName: ServiceName(
            nameAr: detailedPackage.packageInfo.nameAr,
            nameEn: detailedPackage.packageInfo.nameEn,
          ),
          rawDescription: const ServiceDescription(descAr: '', descEn: ''),
          active: true,
          addons: allAddons,
        );

        emit(
          state.copyWith(
            status: BookingStatus.initial,
            selectedService: service,
            washId: wash.washId,
            subscriptionId: subscriptionId,
            includedAddonIds: includedIds,
            optionalAddonIds: optionalIds,
          ),
        );
      },
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
        clearSelectedDate: date == null,
        clearSelectedTime: dateChanged || time == null,
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
      packageId: service.id!,
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
      packageId: state.selectedService!.id!,
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
    emit(state.copyWith(status: BookingStatus.loading));
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
