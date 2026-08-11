import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/networking/exceptions/failure.dart';
import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../domain/configs/booking_flow_config.dart';
import '../../data/models/quote_model.dart';
import '../../../my_bookings/data/models/booking_response_model/breakdown.dart';
import '../../../my_bookings/data/models/booking_response_model/quote_line.dart';
import '../../data/models/payment_init_model.dart';
import '../../data/repos/booking_repository.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import '../../../../core/enums/payment_method_enum.dart';
import '../../domain/strategies/booking_submit_strategy.dart';
import 'booking_state.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import 'package:aqua_go/features/home/data/models/add_on_model.dart';
import 'package:aqua_go/features/home/data/repos/services_repository.dart';
import 'package:aqua_go/features/subscriptions/data/repos/subscriptions_repository.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_wash.dart';
import 'package:aqua_go/features/subscriptions/data/models/subscription_response_model/subscription_included_allowance.dart';

Set<int> remapAddonSelections(
  List<AddOnModel> oldAddons,
  Set<int> selectedIndices,
  List<AddOnModel> freshAddons,
) {
  final remapped = <int>{};
  for (final idx in selectedIndices) {
    if (idx < 0 || idx >= oldAddons.length) continue;
    final id = oldAddons[idx].id;
    if (id == null) continue;
    final newIdx = freshAddons.indexWhere((a) => a.id == id);
    if (newIdx != -1) remapped.add(newIdx);
  }
  return remapped;
}

class QuoteRefresh {
  const QuoteRefresh({this.quote, this.droppedPromoReason});

  final QuoteModel? quote;

  final String? droppedPromoReason;

  bool get promoDropped => droppedPromoReason != null;
}

class OfferApplication {
  const OfferApplication({this.quote, this.settled = false});

  final QuoteModel? quote;

  final bool settled;

  bool get applied => quote != null;
}

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _bookingRepo;
  final SubscriptionsRepository _subscriptionsRepo;
  final ServicesRepository _servicesRepo;
  final BookingFlowConfig _flowConfig;
  final BookingSubmitStrategy _submitStrategy;

  BookingCubit({
    required BookingRepository bookingRepo,
    required SubscriptionsRepository subscriptionsRepo,
    required ServicesRepository servicesRepo,
    BookingFlowConfig flowConfig = BookingFlowConfig.normal,
    required BookingSubmitStrategy submitStrategy,
  }) : _bookingRepo = bookingRepo,
       _subscriptionsRepo = subscriptionsRepo,
       _servicesRepo = servicesRepo,
       _flowConfig = flowConfig,
       _submitStrategy = submitStrategy,
       super(BookingState(flowConfig: flowConfig));

  void initBooking(
    ServiceModel? service, {
    MyCarModel? existingCar,
    AddressModel? existingAddress,
    DateTime? existingDate,
    DateTime? existingSlotStart,
    String? subscriptionId,
    String? washId,
    String? giftCode,
    String? offerTitleAr,
    String? offerTitleEn,
    int? offerListPriceMinor,
    int? offerTargetPriceMinor,
  }) {
    emit(
      BookingState(
        status: BookingStatus.initial,

        selectedService: service,
        selectedCar: existingCar,
        selectedAddress: existingAddress,
        selectedDate: existingDate,
        selectedSlotStart: existingSlotStart,
        flowConfig: _flowConfig,
        subscriptionId: subscriptionId,
        washId: washId,
        giftCode: giftCode,
        offerListPriceMinor: (offerListPriceMinor ?? 0) > 0
            ? offerListPriceMinor
            : null,
        offerTargetPriceMinor: (offerTargetPriceMinor ?? 0) > 0
            ? offerTargetPriceMinor
            : null,

        offerTitleAr: offerTitleAr,
        offerTitleEn: offerTitleEn,
      ),
    );

    if (subscriptionId != null) {
      fetchSubscriptionDetails(subscriptionId);
    }

    if (existingDate != null) {
      fetchAvailability(targetDate: existingDate);
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

        _resolvePackageServices(detailedPackage.packageInfo.bundledServices);
      },
    );
  }

  Future<void> _resolvePackageServices(
    List<ServiceModel> bundledServices,
  ) async {
    if (bundledServices.isEmpty) {
      emit(
        state.copyWith(
          packageServicesLoading: false,
          packageServicesLoadFailed: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        packageServices: bundledServices,
        packageServicesLoading: false,
        packageServicesLoadFailed: false,
        // Auto-select when exactly one included service exists.
        selectedPackageService: bundledServices.length == 1
            ? bundledServices.first
            : null,
      ),
    );
  }

  Future<void> refreshCatalog() async {
    if (state.flowConfig.isPackage) {
      final subscriptionId = state.subscriptionId;
      if (subscriptionId != null) {
        await fetchSubscriptionDetails(subscriptionId);
      }
      return;
    }
    if (!state.flowConfig.isNormal) return;
    final current = state.selectedService;
    if (current == null || current.id == null) return;

    final result = await _servicesRepo.fetchServices();
    result.fold((_) {}, (services) {
      ServiceModel? fresh;
      for (final s in services) {
        if (s.id == current.id) {
          fresh = s;
          break;
        }
      }
      if (fresh == null) return;
      emit(
        state.copyWith(
          selectedService: fresh,
          selectedServiceIndices: remapAddonSelections(
            current.addons,
            state.selectedServiceIndices,
            fresh.addons,
          ),
        ),
      );
    });
  }

  Future<void> retryPackageServices() async {
    final subscriptionId = state.subscriptionId;
    if (subscriptionId == null) return;
    await fetchSubscriptionDetails(subscriptionId);
  }

  /// Records the customer's chosen included service for a package wash.
  void selectPackageService(ServiceModel service) {
    emit(state.copyWith(selectedPackageService: service, clearError: true));
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

  /// [slotStart] is the availability slot's own `start` instant — never a
  /// display label.
  void updateDateTime(DateTime? date, DateTime? slotStart) {
    final dateChanged = date != state.selectedDate;
    emit(
      state.copyWith(
        selectedDate: date,
        selectedSlotStart: dateChanged ? null : slotStart,
        clearSelectedDate: date == null,
        clearSelectedSlotStart: dateChanged || slotStart == null,
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

    // Wire value — built locale-independently so a ZERODIGIT device locale
    // can never send Arabic-Indic digits as the `date` query parameter.
    final dateStr = toWireDate(date);

    // Get zoneId
    String? zoneId = address.zoneId;
    if (zoneId == null || zoneId.isEmpty) {
      emit(state.copyWith(isAvailabilityLoading: true));
      final result = await _bookingRepo.checkZoneAvailability(
        address.lat,
        address.lng,
      );
      final (fetchedZoneId, zoneFailure) = result.fold(
        (failure) => (null, failure),
        (data) => (data['zoneId'] as String?, null),
      );
      if (fetchedZoneId == null) {
        // Surface the backend zone/out-of-area reason; fall back to a localized
        // generic when the failure carries no message.
        final reason = zoneFailure?.message;
        emit(
          state.copyWith(
            isAvailabilityLoading: false,
            errorMessage: (reason != null && reason.isNotEmpty)
                ? reason
                : LocaleKeys.snackbar_default_error.tr(),
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

  /// Prices the current selection, optionally with a promo/offer/points.
  Future<QuoteModel?> fetchQuote({
    String? promoCode,
    String? offerId,
    int? pointsToApply,
  }) async {
    final result = await _priceAndPublish(
      promoCode: promoCode,
      offerId: offerId,
      pointsToApply: pointsToApply,
    );
    return result?.fold((_) => null, (quote) => quote);
  }

  /// Prices the current selection and publishes the outcome — the quote on the
  /// state on success, the server's message on it on rejection.
  Future<Either<Failure, QuoteModel>?> _priceAndPublish({
    String? promoCode,
    String? offerId,
    int? pointsToApply,
  }) async {
    if (state.selectedService == null || state.selectedAddress == null) {
      return null;
    }

    // The request is going out, so whatever an earlier attempt left behind is
    // no longer true: a retry in flight must show the shimmer, not the error it
    // is busy clearing.
    emit(state.copyWith(status: BookingStatus.loading, priceLoadFailed: false));

    final result = await _requestQuote(
      promoCode: promoCode,
      offerId: offerId,
      pointsToApply: pointsToApply,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BookingStatus.failure,
          errorMessage: failure.message,

          priceLoadFailed: true,
        ),
      ),
      (quote) => _emitQuote(quote, offerId),
    );

    return result;
  }

  static bool _isPromoVerdict(FailureType type) =>
      type == FailureType.validation || type == FailureType.notFound;

  Future<Either<Failure, QuoteModel>> _requestQuote({
    String? promoCode,
    String? offerId,
    int? pointsToApply,
  }) {
    final availableAddons = state.selectedService?.addons ?? [];
    final List<String> addOnIds = [];
    for (final idx in state.selectedServiceIndices) {
      if (idx < availableAddons.length) {
        final id = availableAddons[idx].id;
        if (id != null) addOnIds.add(id);
      }
    }
    // A service booking carries a single vehicle, so car count is 1.
    const int carCount = 1;

    return _bookingRepo.getQuote(
      packageId: state.selectedService!.id!,
      lat: state.selectedAddress!.lat,
      lng: state.selectedAddress!.lng,
      promoCode: promoCode,
      offerId: offerId,
      addOnIds: addOnIds,
      carCount: carCount,
      pointsToApply: pointsToApply,
    );
  }

  void _emitQuote(
    QuoteModel quote,
    String? offerId, {
    bool clearOfferPrices = false,
    bool clearRememberedOffer = false,
    bool rememberOffer = false,
  }) {
    final applied = quote.promoCode;
    emit(
      state.copyWith(
        status: BookingStatus.initial,
        quote: quote,
        // A price landed. This is the one place every successful quote path
        // funnels through, so clearing it here covers them all.
        priceLoadFailed: false,
        appliedPromoCode: applied,
        appliedOfferId: applied == null ? null : offerId,
        // Only an offer that actually PRICED something is worth offering back;
        // a quote the server answered without a code carries no deal to
        // restore, whatever it was asked for.
        rememberedOfferId: (rememberOffer && applied != null) ? offerId : null,
        clearPromo: applied == null,
        clearOfferId: offerId == null,
        clearOfferPrices: clearOfferPrices,
        clearRememberedOffer: clearRememberedOffer,
      ),
    );
  }

  /// Applies a manually typed code to the current selection. The chip only
  /// lights up once the backend has returned a quote priced with it.
  Future<QuoteModel?> applyPromoCode(String code) =>
      fetchQuote(promoCode: code);

  Future<OfferApplication> applyOffer(String offerId) async {
    // Nothing to price yet, so nothing was asked of the server and the offer is
    // untouched.
    if (state.selectedService == null || state.selectedAddress == null) {
      return const OfferApplication();
    }

    emit(state.copyWith(status: BookingStatus.loading, priceLoadFailed: false));

    var result = await _requestQuote(offerId: offerId);
    final unanswered = result.fold(
      (failure) => !_isPromoVerdict(failure.type),
      (_) => false,
    );
    if (unanswered) {
      result = await _requestQuote(offerId: offerId);
    }

    return result.fold(
      (failure) {
        final settled = _isPromoVerdict(failure.type);
        emit(
          state.copyWith(
            status: BookingStatus.failure,
            errorMessage: failure.message,

            // A SETTLED failure is the server REFUSING the offer, and the two
            clearOfferPrices: settled,

            clearRememberedOffer: settled,
          ),
        );
        return OfferApplication(settled: settled);
      },
      (quote) {
        _emitQuote(quote, offerId, rememberOffer: true);
        return OfferApplication(quote: quote, settled: true);
      },
    );
  }

  /// Re-prices without any promo and clears the applied code.
  Future<QuoteModel?> removePromoCode() => fetchQuote();

  Future<QuoteModel?> repriceForDisplayWithoutPromo() async {
    if (state.selectedService == null || state.selectedAddress == null) {
      return null;
    }

    emit(state.copyWith(status: BookingStatus.loading));
    final result = await _requestQuote();

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

  Future<QuoteRefresh> reprice() async {
    if (state.selectedService == null || state.selectedAddress == null) {
      return const QuoteRefresh();
    }
    final promoCode = state.appliedPromoCode;
    final offerId = state.appliedOfferId;

    // Same reason as `_priceAndPublish`: the attempt is live again, so the
    // failed-price state it may be recovering from is cleared on the way out.
    emit(state.copyWith(status: BookingStatus.loading, priceLoadFailed: false));
    final result = await _requestQuote(promoCode: promoCode, offerId: offerId);

    return result.fold(
      (rejection) =>
          _repriceAfter(rejection, promoCode: promoCode, offerId: offerId),
      (quote) async {
        _emitQuote(quote, offerId);
        return QuoteRefresh(quote: quote);
      },
    );
  }

  Future<QuoteRefresh> _repriceAfter(
    Failure rejection, {
    required String? promoCode,
    required String? offerId,
  }) async {
    // Nothing applied means there is nothing to drop and nothing to retry
    // differently; an unanswered request means there is nothing to drop it
    // OVER. Either way the failure is the whole story, and `copyWith` leaves
    // the applied code and offer exactly where they were.
    if (promoCode == null || !_isPromoVerdict(rejection.type)) {
      emit(
        state.copyWith(
          status: BookingStatus.failure,
          errorMessage: rejection.message,

          priceLoadFailed: true,
        ),
      );
      return const QuoteRefresh();
    }

    final offerRefused = offerId != null;

    final clean = await _requestQuote();
    return clean.fold(
      (failure) {
        emit(
          state.copyWith(
            status: BookingStatus.failure,
            errorMessage: failure.message,
            // Both attempts are spent and neither produced a price.
            priceLoadFailed: true,
            clearOfferPrices: offerRefused,
            clearRememberedOffer: offerRefused,
          ),
        );
        return const QuoteRefresh();
      },
      (quote) {
        _emitQuote(
          quote,
          null,
          clearOfferPrices: offerRefused,
          clearRememberedOffer: offerRefused,
        );
        return QuoteRefresh(
          quote: quote,
          droppedPromoReason: rejection.message,
        );
      },
    );
  }

  Future<void> submitBooking() async {
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
          // The offer has been spent on THIS booking. Nothing downstream of a
          // created booking may offer it back.
          clearRememberedOffer: true,
        ),
      ),
    );
  }

  Future<PaymentInitModel?> initiatePayment({int? pointsToApply}) async {
    final quoteId = state.quote?.quoteId;
    if (quoteId == null) {
      emit(
        state.copyWith(
          status: BookingStatus.failure,
          paymentPhase: PaymentPhase.declined,
          errorMessage: 'Missing quote — please re-confirm the booking.',
        ),
      );
      return null;
    }

    // Same wire builder ServiceBookingRequestModel.toJson uses, so payment-init
    // and create can never disagree about the slot.
    final slotStart = state.selectedSlotStart;
    final scheduledAt = slotStart != null ? toWireDateTime(slotStart) : null;

    if (scheduledAt == null) {
      emit(
        state.copyWith(
          status: BookingStatus.failure,
          paymentPhase: PaymentPhase.declined,
          errorMessage: 'Missing booking date/time — please select a slot.',
        ),
      );
      return null;
    }

    // Build the vehicles list in the same shape as ServiceBookingRequestModel.toJson.
    final car = state.selectedCar;
    if (car == null) {
      emit(
        state.copyWith(
          status: BookingStatus.failure,
          paymentPhase: PaymentPhase.declined,
          errorMessage: 'Missing vehicle — please select a car.',
        ),
      );
      return null;
    }

    final Map<String, dynamic> vehicleEntry;
    if (car.id.isNotEmpty) {
      vehicleEntry = {'savedVehicleId': car.id};
    } else {
      vehicleEntry = {
        'plateText': car.plateNumber,
        if (car.carMake?.vehicleMakeName.nameEn != null)
          'vehicleMake': car.carMake!.vehicleMakeName.nameEn,
        if (car.carModel?.vehicleModelName.nameEn != null)
          'vehicleModel': car.carModel!.vehicleModelName.nameEn,
        'vehicleColor': car.color,
        'vehicleYear': car.modelYear,
      };
    }
    final vehicles = [vehicleEntry];

    final attemptNonce = const Uuid().v4();
    emit(
      state.copyWith(
        paymentPhase: PaymentPhase.initiated,
        status: BookingStatus.loading,
      ),
    );
    final result = await _bookingRepo.bookingPaymentInit(
      quoteId: quoteId,
      scheduledAt: scheduledAt,
      vehicles: vehicles,
      attemptNonce: attemptNonce,
      pointsToApply: pointsToApply,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: BookingStatus.failure,
            paymentPhase: PaymentPhase.declined,
            errorMessage: failure.message,
          ),
        );
        return null;
      },
      (init) {
        emit(
          state.copyWith(
            status: BookingStatus.initial,
            paymentPhase: PaymentPhase.none,
            paymentInit: init,
          ),
        );
        return init;
      },
    );
  }

  Future<PaymentInitModel?> initiateWashAddonPayment() async {
    final subscriptionId = state.subscriptionId;
    final washId = state.washId;
    if (subscriptionId == null || washId == null) {
      emit(
        state.copyWith(
          status: BookingStatus.failure,
          paymentPhase: PaymentPhase.declined,
          errorMessage: 'Missing subscription/wash context.',
        ),
      );
      return null;
    }

    // Build the body matching ScheduleWashRequest (same shape as the schedule
    // endpoint, minus scheduledAt which the server ignores for payment-init).
    final availableAddons = state.selectedService?.addons ?? [];
    final List<Map<String, dynamic>> addOns = [];
    for (final idx in state.selectedServiceIndices) {
      if (idx < availableAddons.length) {
        final id = availableAddons[idx].id;
        if (id != null) addOns.add({'addonId': id});
      }
    }

    final vehicleId = state.selectedCar?.id;
    final body = <String, dynamic>{
      'scheduledAt': toWireDateTime(saudiNow()),
      if (vehicleId != null) 'vehicleIds': [vehicleId],
      if (addOns.isNotEmpty) 'addOns': addOns,
    };

    final attemptNonce = const Uuid().v4();
    emit(
      state.copyWith(
        paymentPhase: PaymentPhase.initiated,
        status: BookingStatus.loading,
      ),
    );
    final result = await _subscriptionsRepo.washAddonPaymentInit(
      subscriptionId: subscriptionId,
      washId: washId,
      scheduleBody: body,
      attemptNonce: attemptNonce,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: BookingStatus.failure,
            paymentPhase: PaymentPhase.declined,
            errorMessage: failure.message,
          ),
        );
        return null;
      },
      (init) {
        emit(
          state.copyWith(
            status: BookingStatus.initial,
            paymentPhase: PaymentPhase.none,
            paymentInit: init,
          ),
        );
        return init;
      },
    );
  }

  Future<QuoteModel?> fetchWashChargePreview() async {
    final subscriptionId = state.subscriptionId;
    final washId = state.washId;
    if (subscriptionId == null || washId == null) return null;

    // The preview is going out — clear any earlier failure so a retry in flight
    // reads as pending, exactly as the service flow's quote does.
    emit(state.copyWith(status: BookingStatus.loading, priceLoadFailed: false));

    // Same body shape as initiateWashAddonPayment / the schedule endpoint
    // (scheduledAt is required by the record but ignored for the read-only
    // preview — send a sentinel to pass @NotNull validation).
    final availableAddons = state.selectedService?.addons ?? [];
    final List<Map<String, dynamic>> addOns = [];
    for (final idx in state.selectedServiceIndices) {
      if (idx < availableAddons.length) {
        final id = availableAddons[idx].id;
        if (id != null) addOns.add({'addonId': id});
      }
    }
    final vehicleId = state.selectedCar?.id;
    final body = <String, dynamic>{
      'scheduledAt': toWireDateTime(saudiNow()),
      if (vehicleId != null) 'vehicleIds': [vehicleId],
      if (addOns.isNotEmpty) 'addOns': addOns,
    };

    final result = await _bookingRepo.previewScheduleSubscriptionWash(
      subscriptionId: subscriptionId,
      washId: washId,
      scheduleData: body,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: BookingStatus.failure,
            errorMessage: failure.message,
            priceLoadFailed: true,
          ),
        );
        return null;
      },
      (data) {
        final quote = _quoteFromWashPreview(data);
        emit(
          state.copyWith(
            status: BookingStatus.initial,
            quote: quote,
            priceLoadFailed: false,
          ),
        );
        return quote;
      },
    );
  }

  QuoteModel _quoteFromWashPreview(Map<String, dynamic> data) {
    final breakdownJson = data['breakdown'] as Map<String, dynamic>?;
    final Breakdown? breakdown = breakdownJson != null
        ? Breakdown.fromJson(breakdownJson)
        : null;
    final int chargeTotalMinor = data['chargeTotalMinor'] != null
        ? int.tryParse(data['chargeTotalMinor'].toString()) ?? 0
        : 0;

    final List<({String? refId, int grossMinor})> payable = [];
    final addonLines = data['addonLines'];
    if (addonLines is List) {
      for (final raw in addonLines) {
        if (raw is! Map) continue;
        final charged = raw['chargedMinor'] != null
            ? int.tryParse(raw['chargedMinor'].toString()) ?? 0
            : 0;
        payable.add((refId: raw['addonId']?.toString(), grossMinor: charged));
      }
    }

    final int lastPaidIndex = payable.lastIndexWhere((p) => p.grossMinor > 0);
    final int totalGross = payable.fold(0, (s, p) => s + p.grossMinor);
    final int? netTotal = breakdown?.netMinor;
    final List<QuoteLine> lines = [];
    int netAssigned = 0;
    for (int i = 0; i < payable.length; i++) {
      final p = payable[i];
      final int lineNet;
      if (p.grossMinor <= 0) {
        lineNet = 0;
      } else if (netTotal == null || totalGross <= 0) {
        lineNet = p.grossMinor;
      } else if (i == lastPaidIndex) {
        lineNet = netTotal - netAssigned;
      } else {
        lineNet = (p.grossMinor * netTotal / totalGross).round();
      }
      if (p.grossMinor > 0) {
        netAssigned += lineNet;
      }
      lines.add(
        QuoteLine(
          kind: 'ADDON',
          refId: p.refId,
          grossMinor: p.grossMinor,
          netMinor: lineNet,
          vatMinor: p.grossMinor - lineNet,
        ),
      );
    }

    final resolvedBreakdown =
        breakdown ??
        Breakdown(
          grossMinor: chargeTotalMinor,
          totalMinor: chargeTotalMinor,
          currency: 'SAR',
        );
    if (resolvedBreakdown.totalMinor == null &&
        resolvedBreakdown.grossMinor == null) {
      resolvedBreakdown.totalMinor = chargeTotalMinor;
      resolvedBreakdown.grossMinor = chargeTotalMinor;
    }

    return QuoteModel(
      quoteId: 'wash-preview',
      currency: resolvedBreakdown.currency ?? 'SAR',
      expiresAt: saudiNow(),
      breakdown: resolvedBreakdown,
      lines: lines,
    );
  }

  /// The user dismissed the SDK sheet without paying.
  void onPaymentCancelled() {
    emit(state.copyWith(paymentPhase: PaymentPhase.cancelled));
  }

  Future<void> completeBookingAfterPayment(String moyasarPaymentId) async {
    emit(
      state.copyWith(
        paymentPhase: PaymentPhase.paidCreating,
        status: BookingStatus.loading,
      ),
    );

    final result = await _submitStrategy.submit(
      repo: _bookingRepo,
      state: state,
      moyasarPaymentId: moyasarPaymentId,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BookingStatus.failure,
          paymentPhase: PaymentPhase.createUnconfirmed,
          errorMessage: failure.message,
        ),
      ),
      (bookingResponse) => emit(
        state.copyWith(
          status: BookingStatus.success,
          paymentPhase: PaymentPhase.none,
          createdBooking: bookingResponse,
          clearPaymentInit: true,
          // Spent on this booking — see [submitBooking].
          clearRememberedOffer: true,
        ),
      ),
    );
  }
}
