import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../domain/configs/booking_flow_config.dart';
import '../../data/models/quote_model.dart';
import '../../../my_bookings/data/models/booking_response_model/breakdown.dart';
import '../../../my_bookings/data/models/booking_response_model/quote_line.dart';
import '../../data/models/payment_init_model.dart';
import '../../data/models/day_time_model.dart';
import '../../data/repos/booking_repository.dart';
import '../../../../core/enums/payment_method_enum.dart';
import '../../domain/strategies/booking_submit_strategy.dart';
import 'booking_state.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
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
    DateTime? existingDate,
    String? existingTime,
    String? subscriptionId,
    String? washId,
  }) {
    emit(
      BookingState(
        status: BookingStatus.initial,
        selectedService: service,
        selectedCar: existingCar,
        selectedAddress: existingAddress,
        selectedDate: existingDate,
        selectedTime: existingTime,
        flowConfig: _flowConfig,
        subscriptionId: subscriptionId,
        washId: washId,
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

        // Resolve the package's bundled (included) services so the customer can
        // pick which one to wash. Sourced from the catalog-resolved
        // bundledServices field (incl. inactive services) — no /services join.
        _resolvePackageServices(detailedPackage.packageInfo.bundledServices);
      },
    );
  }

  /// Populates the service picker from the catalog-resolved [bundledServices]
  /// (already carrying id + bilingual name + active, in bundle order) so the
  /// customer can pick one included service per wash. Renders EVERY bundled
  /// service — including inactive ones — because an inactive-but-bundled service
  /// is still a valid pick (the schedule call validates membership in the frozen
  /// bundle, not active-ness). Auto-selects when the bundle has exactly one
  /// service (no needless step).
  ///
  /// No longer joins against the active-only /services feed: that dropped
  /// inactive ids and forced the picker into a load-failed error state for any
  /// package whose bundled services had been deactivated.
  Future<void> _resolvePackageServices(List<ServiceModel> bundledServices) async {
    if (bundledServices.isEmpty) {
      // Genuine data error: the backend returned an empty bundledServices list.
      // Surface the inline error + retry rather than a hidden picker (which
      // would submit serviceId=null and let the backend pick unseen).
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

  /// Retries resolving the package's bundled services after a load failure by
  /// re-running the subscription detail fetch (which re-derives the resolved
  /// bundledServices list). No-op outside the package flow. Reachable only when
  /// the backend genuinely returns an empty bundledServices list.
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

  Future<QuoteModel?> fetchQuote({String? promoCode}) async {
    if (state.selectedService == null || state.selectedAddress == null) {
      return null;
    }

    emit(state.copyWith(status: BookingStatus.loading));

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

    final result = await _bookingRepo.getQuote(
      packageId: state.selectedService!.id!,
      lat: state.selectedAddress!.lat,
      lng: state.selectedAddress!.lng,
      promoCode: promoCode,
      addOnIds: addOnIds,
      carCount: carCount,
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

  /// Pay-before-create step 2 for normal bookings (spec §4.2): re-validate the
  /// quote + soft-hold the slot, then expose the {amount, givenId, metadata}
  /// the Moyasar SDK needs.
  ///
  /// Builds `scheduledAt` (bare ISO-8601 Saudi time) and the `vehicles` list
  /// from the cubit state so the backend can run the same slot/lead/car checks
  /// it runs at create time (B1 fix — PaymentInitRequest requires all three
  /// fields: quoteId, scheduledAt, vehicles).
  Future<PaymentInitModel?> initiatePayment() async {
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

    // Build scheduledAt in the exact format DayTimeModel produces (matches
    // ServiceBookingRequestModel.toJson and the backend bare-ISO-8601 contract).
    final scheduledAt =
        (state.selectedDate != null && state.selectedTime != null)
        ? DayTimeModel(
            date: state.selectedDate!,
            rawTime: state.selectedTime!,
          ).toScheduledAtString()
        : null;

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

  /// Pay-before-confirm step 1 for subscription wash add-ons (spec §4.4 / A2):
  /// sends the selected add-on ids + vehicle to the server, receives the payable
  /// delta as a Moyasar SDK payload. Only valid in [BookingFlowType.package]
  /// flow when the total add-on cost is > 0.
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
      // scheduledAt is required by the backend record but not used for
      // payment-init; send a sentinel to pass @NotNull validation.
      'scheduledAt': DateTime.now().toUtc().toIso8601String(),
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

  /// Subscription-wash summary preview (UC-C13 — spec §4). Read-only dry-run of
  /// the schedule endpoint: classifies the selected add-ons into free/paid and
  /// returns the payable charge + VAT breakdown WITHOUT persisting or charging.
  ///
  /// Without this, the package summary had no quote at all, so it rendered
  /// 0.00 everywhere and the Confirm gate bare-submitted a paid wash → the
  /// backend rejected it with 422 SUBSCRIPTION_WASH_ADDON_PAYMENT_REQUIRED.
  /// We map the preview into a synthetic [QuoteModel] (breakdown drives
  /// subtotal/VAT/total; addonLines drive the per-row add-on display) and emit
  /// it into `state.quote` so the existing summary render + Confirm gate work
  /// unchanged. NO client-side price/VAT math — every amount comes from the
  /// backend preview.
  Future<QuoteModel?> fetchWashChargePreview() async {
    final subscriptionId = state.subscriptionId;
    final washId = state.washId;
    if (subscriptionId == null || washId == null) return null;

    emit(state.copyWith(status: BookingStatus.loading));

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
      'scheduledAt': DateTime.now().toUtc().toIso8601String(),
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
        // Soft failure: keep the summary usable. The Confirm gate's
        // hasPayableAddon safety net (booking_summary_view) still routes a
        // paid wash through addon-payment-init even without a preview.
        emit(
          state.copyWith(
            status: BookingStatus.initial,
            errorMessage: failure.message,
          ),
        );
        return null;
      },
      (data) {
        final quote = _quoteFromWashPreview(data);
        emit(state.copyWith(status: BookingStatus.initial, quote: quote));
        return quote;
      },
    );
  }

  /// Maps a `WashChargePreview` JSON payload into a synthetic [QuoteModel].
  ///
  /// - `breakdown` (grossMinor/netMinor/vatMinor) → drives subtotal/VAT/total.
  /// - paid `addonLines` → ADDON [QuoteLine]s (refId = addonId for name lookup;
  ///   `chargedMinor` is the payable GROSS for that line). Each line's NET is
  ///   distributed from `breakdown.netMinor` proportionally to its gross so the
  ///   add-on rows (rendered at line.net) sum to the subtotal (breakdown.net).
  /// The package submit path never reads quoteId, so a synthetic id is safe.
  QuoteModel _quoteFromWashPreview(Map<String, dynamic> data) {
    final breakdownJson = data['breakdown'] as Map<String, dynamic>?;
    final Breakdown? breakdown = breakdownJson != null
        ? Breakdown.fromJson(breakdownJson)
        : null;
    final int chargeTotalMinor = data['chargeTotalMinor'] != null
        ? int.tryParse(data['chargeTotalMinor'].toString()) ?? 0
        : 0;

    // First pass: collect the PAYABLE add-on lines with their GROSS charge.
    // Only payable (chargedMinor > 0) lines belong on the payment summary;
    // covered (free) lines stay off it so rows don't imply a charge.
    final List<({String? refId, int grossMinor})> payable = [];
    final addonLines = data['addonLines'];
    if (addonLines is List) {
      for (final raw in addonLines) {
        if (raw is! Map) continue;
        final charged = raw['chargedMinor'] != null
            ? int.tryParse(raw['chargedMinor'].toString()) ?? 0
            : 0;
        if (charged <= 0) continue;
        payable.add((refId: raw['addonId']?.toString(), grossMinor: charged));
      }
    }

    // Second pass: WashAddonLine carries no per-line net — only the GROSS
    // chargedMinor — while the summary renders each add-on row at line.net and
    // the subtotal at breakdown.net. So we DISTRIBUTE the backend-provided
    // breakdown.netMinor across the gross add-on lines proportionally
    // (lineNet = chargedMinor * breakdown.net / breakdown.gross), absorbing the
    // rounding remainder into the LAST line so the rows sum EXACTLY to
    // breakdown.netMinor. The total stays breakdown.gross (still on grossMinor).
    // This is pure distribution of backend values — no client-side VAT math.
    final int totalGross = payable.fold(0, (s, p) => s + p.grossMinor);
    final int? netTotal = breakdown?.netMinor;
    final List<QuoteLine> lines = [];
    int netAssigned = 0;
    for (int i = 0; i < payable.length; i++) {
      final p = payable[i];
      final int lineNet;
      if (netTotal == null || totalGross <= 0) {
        // No breakdown net to distribute (older payload / single-line edge) —
        // fall back to the gross charge so the row still shows a sane amount.
        lineNet = p.grossMinor;
      } else if (i == payable.length - 1) {
        // Last line absorbs the rounding remainder → Σ net == breakdown.netMinor.
        lineNet = netTotal - netAssigned;
      } else {
        lineNet = (p.grossMinor * netTotal / totalGross).round();
      }
      netAssigned += lineNet;
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

    return QuoteModel(
      quoteId: 'wash-preview',
      totalMinor: breakdown?.grossMinor ?? chargeTotalMinor,
      vatMinor: breakdown?.vatMinor ?? 0,
      currency: breakdown?.currency ?? 'SAR',
      expiresAt: DateTime.now().toUtc(),
      promoDiscountMinor: 0,
      breakdown: breakdown,
      lines: lines,
    );
  }

  /// The user dismissed the SDK sheet without paying.
  void onPaymentCancelled() {
    emit(state.copyWith(paymentPhase: PaymentPhase.cancelled));
  }

  /// Pay-before-create step 4 (spec §4.2): the SDK returned a verified `paid`
  /// payment; create the booking with idempotency `booking-create:{id}`. On a
  /// 409 slot-race the server auto-refunds and the UI reflects [refundPending].
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
          paymentPhase: PaymentPhase.refundPending,
          errorMessage: failure.message,
        ),
      ),
      (bookingResponse) => emit(
        state.copyWith(
          status: BookingStatus.success,
          paymentPhase: PaymentPhase.none,
          createdBooking: bookingResponse,
          clearPaymentInit: true,
        ),
      ),
    );
  }
}
