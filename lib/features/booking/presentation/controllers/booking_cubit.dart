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

/// Remaps index-based add-on selections ([BookingState.selectedServiceIndices])
/// onto [freshAddons] by add-on ID. Selections whose add-on no longer exists
/// are dropped. Top-level + pure for unit-testing.
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

/// Outcome of [BookingCubit.reprice]: the fresh quote, plus the rejection the
/// server gave for the promo it had to drop to get one.
class QuoteRefresh {
  const QuoteRefresh({this.quote, this.droppedPromoReason});

  /// The re-priced quote, or null when pricing failed outright.
  final QuoteModel? quote;

  /// Non-null when the applied promo no longer validated and was removed to
  /// obtain [quote] — the server's own reason, which is what the customer is
  /// owed as an explanation.
  final String? droppedPromoReason;

  bool get promoDropped => droppedPromoReason != null;
}

/// Outcome of [BookingCubit.applyOffer].
///
/// Three outcomes, not two, for the reason `OfferRevalidation` gives on the
/// offers surface: "the server refused this offer" and "I could not reach the
/// server" must not be treated the same. The first is a verdict and consumes
/// the customer's single-shot offer handoff; the second is a failure to ASK,
/// and consuming the offer on it charges them full price for a deal they
/// accepted and were never told they had lost.
class OfferApplication {
  const OfferApplication({this.quote, this.settled = false});

  /// The quote priced WITH the offer, or null when it was not applied.
  final QuoteModel? quote;

  /// True when the offer's fate is decided — it was applied, or it was refused
  /// on its merits. False when nothing was decided: no network, a timeout, a
  /// 5xx, or no selection to price yet. A caller holding the offer keeps
  /// holding it while this is false.
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
        // WHY THERE IS NO "changing the service drops the held offer" BRANCH.
        // The service is fixed HERE, once, for the whole flow: a SERVICE offer
        // deep-links at the wash it names. `selectedService` is written in
        // exactly THREE places in this cubit, and neither of the other two can
        // re-point an offer-driven booking at a different wash:
        //  1. HERE, from the offer's own service.
        //  2. `refreshCatalog` — re-reads the SAME id and swaps in a fresh copy
        //     of the same wash, never a different one.
        //  3. `fetchSubscriptionDetails` — synthesises a PACKAGE pseudo-service
        //     from the subscription. It runs only in the package flow, which is
        //     entered with a subscriptionId and never carries the two offer
        //     figures below (a SERVICE offer hands in a serviceId, not a
        //     subscription), so there is nothing of the offer's for it to
        //     invalidate.
        // So the case is vacuous rather than missing, and nothing recorded that.
        //
        // It stops being vacuous the moment a picker can re-point an in-flight
        // booking at a DIFFERENT service. An offer prices ONE wash, so that
        // change would have to drop all three things below that describe it:
        // the two display figures, and the offer id
        // (`PendingPromoCode` / `BookingState.appliedOfferId`) the summary
        // prices with. Leaving them would show a wash at another wash's deal.
        selectedService: service,
        selectedCar: existingCar,
        selectedAddress: existingAddress,
        selectedDate: existingDate,
        selectedSlotStart: existingSlotStart,
        flowConfig: _flowConfig,
        subscriptionId: subscriptionId,
        washId: washId,
        giftCode: giftCode,
        // Both are DISPLAY figures the SERVICE offer card handed over, and
        // they enter the flow here because that is the only moment the offer
        // is in scope. A 0 target means the offer carries no deal at all (a
        // shortcut card), which is not the same statement as "free" — it is
        // normalised away so no caller downstream has to know the difference.
        offerListPriceMinor:
            (offerListPriceMinor ?? 0) > 0 ? offerListPriceMinor : null,
        offerTargetPriceMinor:
            (offerTargetPriceMinor ?? 0) > 0 ? offerTargetPriceMinor : null,
        // Both languages of the offer's own name, so the summary's re-apply
        // card can say WHICH offer it is putting back rather than "your offer".
        // A fresh state also means `rememberedOfferId` starts null: an offer
        // belongs to the booking it was taken for and never to the next one.
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
  Future<void> _resolvePackageServices(
    List<ServiceModel> bundledServices,
  ) async {
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

  /// Refetches the current catalogue so displayed add-on prices are fresh.
  /// Service flow: rebinds [BookingState.selectedService] and remaps the
  /// index-based selections by add-on ID ([remapAddonSelections]). Package
  /// flow: re-runs [fetchSubscriptionDetails]. Reschedule: no-op (booking
  /// content is frozen at creation). Failures keep the existing snapshot —
  /// the server quote stays authoritative for money.
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
    result.fold(
      (_) {},
      (services) {
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
      },
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
    emit(
      state.copyWith(
        status: BookingStatus.loading,
        priceLoadFailed: false,
      ),
    );

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
          // A price failure specifically — the summary reads this to tell "no
          // price is coming" from "no price yet" and offer a retry rather than
          // shimmer forever (booking_state.dart, `priceLoadFailed`).
          priceLoadFailed: true,
        ),
      ),
      (quote) => _emitQuote(quote, offerId),
    );

    return result;
  }

  /// Whether [type] is the server's VERDICT on the promo the request carried,
  /// rather than a failure to obtain one.
  ///
  /// A promo rejection comes back 400 / 409 / 422 ([FailureType.validation]);
  /// an unknown offer comes back 404 ([FailureType.notFound]). Everything else
  /// — no network, a timeout, a 5xx, a cancelled request — says nothing at all
  /// about the code or the offer, and must never be read as one being refused.
  static bool _isPromoVerdict(FailureType type) =>
      type == FailureType.validation || type == FailureType.notFound;

  /// Prices the current selection without touching the emitted state, so a
  /// caller that has to try twice (see [reprice]) does not flash a rejection
  /// the customer is about to be given a resolution for.
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

  /// Publishes a freshly priced quote and the promo it was priced with.
  ///
  /// The quote echoes the code the server actually applied — normalised to
  /// upper case, and resolved from the offer when an offerId was sent — so it,
  /// not the request, is what the applied state is taken from. A quote that
  /// came back without a code clears both halves of the promo.
  ///
  /// [offerId] is the offer this quote was priced FOR, and it is authoritative
  /// in both directions: null means the order carries no offer attribution, so
  /// any id held from an earlier quote is dropped rather than retained. A typed
  /// code applied over a live offer must not inherit that offer — the
  /// redemption's `offer_id` is the only record of which offer drove the sale.
  /// [clearOfferPrices] drops the two display figures the offer card handed in,
  /// and is set ONLY by a caller holding the server's REFUSAL of that offer (see
  /// [_repriceAfter]). Defaulted off because every other caller is publishing a
  /// quote, which says nothing about the offer's fate.
  ///
  /// [rememberOffer] records [offerId] as the offer THIS FLOW took, which is a
  /// different fact from the one `appliedOfferId` carries and outlives it: the
  /// attribution is dropped the moment a quote comes back that the offer did
  /// not drive, and without a record beside it a typed code applied over a live
  /// offer destroyed it for the session. Set by [applyOffer] on the way in and
  /// on a re-apply; never unset here — dropping it takes the server's refusal.
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

  /// Applies a merchandising offer. Only the offer id goes on the wire — the
  /// server resolves its linked code, and sending both is a 400.
  ///
  /// Reports whether the offer was SETTLED as well as whether it was applied.
  /// The offer arrives here through a single-shot handoff that the caller has
  /// already drained, and only a verdict earns that: an unreachable server has
  /// said nothing about the offer, so the caller puts it back.
  ///
  /// An unanswered first attempt is retried ONCE, still carrying the offer,
  /// before that verdict-less outcome is reported. The caller's next move is a
  /// quote either way — it re-prices the order so the summary stays usable —
  /// and pricing that one bare would drop a deal the customer accepted over a
  /// dropped connection or a single 5xx, which the retry usually survives.
  /// Exactly once: a second silence is a real outage, and looping would sit on
  /// the loading overlay with nothing to show for it.
  ///
  /// Both attempts go through [_requestQuote], which does NOT touch the emitted
  /// state, so the customer is shown ONE outcome rather than a rejection that
  /// is immediately overwritten.
  Future<OfferApplication> applyOffer(String offerId) async {
    // Nothing to price yet, so nothing was asked of the server and the offer is
    // untouched.
    if (state.selectedService == null || state.selectedAddress == null) {
      return const OfferApplication();
    }

    // The THIRD way into a price call, alongside `_priceAndPublish` and
    // `reprice`, and it clears the failed-price state for the same reason they
    // do: a retry re-takes a held offer and comes through HERE, so leaving the
    // flag set would keep offering a Retry for a request already in flight.
    emit(
      state.copyWith(
        status: BookingStatus.loading,
        priceLoadFailed: false,
      ),
    );

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
            // display figures the offer card handed in stop being true the
            // moment it does: the order will be priced without the offer, so
            // details would otherwise still promise a deal the customer cannot
            // have and then charge more at the summary. Only here — an
            // unanswered request (settled false) has said nothing about the
            // offer, and the caller puts it back for the next entry.
            clearOfferPrices: settled,
            // The same verdict, applied to the same fact from the other side:
            // an offer the server has refused is not one to keep offering back
            // from the summary. A card that re-runs the identical rejection is
            // a dead button, and the customer has no way to tell it is dead.
            // Unsettled changes nothing — see the note above.
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

  /// Re-prices the current selection with NO promo and NO offer on the wire,
  /// leaving the applied code ON the state. Display-only.
  ///
  /// This is the booking-details screen's re-quote. Per the owner's ruling
  /// (plan §6.93) the discount does not appear before the payment page: details
  /// always prices the bare selection, and the summary — which re-quotes WITH
  /// the applied code on entry and breaks the figure down original → discount →
  /// total — is where the discount first shows and is explained.
  ///
  /// [BookingState.appliedPromoCode] and [BookingState.appliedOfferId] survive
  /// this call untouched, which is the entire reason it is not [removePromoCode]
  /// and does not go through [_emitQuote]. Clearing them here would throw away
  /// the offer the customer took on the offers surface, so the summary would
  /// have nothing left to apply and they would be charged full price for it.
  /// [_emitQuote] takes the applied code FROM the quote, and this quote is bare
  /// by construction, so routing through it would do exactly that.
  ///
  /// A dead code cannot be detected here, because none is sent. The summary
  /// owns that: it re-quotes with the code on entry and states the server's
  /// rejection through its own drop-reason path.
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

  /// Re-prices the current selection PRESERVING whatever promo is applied —
  /// used by every re-quote the SUMMARY makes on the customer's behalf rather
  /// than at their explicit request (arriving back on the screen with a code
  /// already applied, the price-lock refresh once the quote's TTL lapses).
  /// Re-quoting bare there would silently throw the customer's discount away on
  /// the one screen that is meant to show it.
  ///
  /// The booking-details screen deliberately does NOT come here — it prices the
  /// bare selection through [repriceForDisplayWithoutPromo], because no discount
  /// shows before the payment page (plan §6.93).
  ///
  /// When the applied code no longer VALIDATES — its cap was consumed, the
  /// campaign ended, or the order no longer clears its minimum — retrying with
  /// the same dead code repeats the same rejection forever, and the customer
  /// has no way out but to guess. So the code is dropped, the selection is
  /// re-priced WITHOUT it, and the reason the server gave comes back on
  /// [QuoteRefresh.droppedPromoReason] for the caller to state.
  ///
  /// That drop is reserved for a VERDICT. A timeout or a 5xx says nothing
  /// about the code, and dropping it on one would quietly re-price the order at
  /// full price the moment the connection came back — the customer's own
  /// discount removed by a network blip, on the screen that exists to show it.
  /// The offers surface makes the same distinction for the same reason
  /// (`OfferUncheckable`). On an unanswered request the applied code and offer
  /// stay exactly where they were and the failure is raised as itself, so the
  /// customer can retry with their code intact.
  Future<QuoteRefresh> reprice() async {
    if (state.selectedService == null || state.selectedAddress == null) {
      return const QuoteRefresh();
    }
    final promoCode = state.appliedPromoCode;
    final offerId = state.appliedOfferId;

    // Same reason as `_priceAndPublish`: the attempt is live again, so the
    // failed-price state it may be recovering from is cleared on the way out.
    emit(
      state.copyWith(
        status: BookingStatus.loading,
        priceLoadFailed: false,
      ),
    );
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

  /// The failing half of [reprice].
  ///
  /// [rejection] is the failure the priced-with-promo attempt came back with,
  /// and [promoCode] whatever was applied when it went out. [offerId] is the
  /// offer that request carried, and it decides whether the two display figures
  /// the offer card handed in are still true: a SETTLED rejection of a request
  /// that carried an offer is the server REFUSING that offer, exactly as it is
  /// on the handoff-apply path ([applyOffer]), and the pair stops being true the
  /// moment it does. This is the SECOND way that refusal reaches the customer —
  /// the offer applied cleanly on the way in, and the cap was consumed before
  /// they came back — and leaving the figures behind here left details promising
  /// a deal the summary then declined to honour.
  ///
  /// The same discipline as [applyOffer]: only a VERDICT clears them. The guard
  /// below returns before that on an unanswered request, so a timeout or a 5xx
  /// leaves the pair exactly where it was.
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
          // No quote came back, so a flow with none yet has nothing to show.
          // Harmless where one is already on the state: `resolvePriceDisplay`
          // lets an existing quote win, because it is still a real figure.
          priceLoadFailed: true,
        ),
      );
      return const QuoteRefresh();
    }

    // Past the guard the rejection is a VERDICT, so a request that carried an
    // offer has had that offer refused. What the second attempt goes on to do
    // cannot change that, so both branches below drop the figures — and the
    // remembered offer with them, for the reason [applyOffer] gives: the
    // summary must not keep offering back an offer the server has ended.
    final offerRefused = offerId != null;

    // Second attempt WITHOUT the code. Its own failure is the one worth
    // surfacing — at that point nothing about the promo is left to explain.
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

  /// Pay-before-create step 2 for normal bookings (spec §4.2): re-validate the
  /// quote + soft-hold the slot, then expose the {amount, givenId, metadata}
  /// the Moyasar SDK needs.
  ///
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
      // payment-init; send a sentinel to pass @NotNull validation. Bare
      // Asia/Riyadh local, never a `Z`-suffixed instant — the sentinel has to
      // satisfy the same wire contract as a real value.
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

    // The preview is going out — clear any earlier failure so a retry in flight
    // reads as pending, exactly as the service flow's quote does.
    emit(
      state.copyWith(
        status: BookingStatus.loading,
        priceLoadFailed: false,
      ),
    );

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
        // Reported, exactly as a failed /quote is on the service flow
        // (`_priceAndPublish`), because the summary now WAITS on this preview:
        // it is the package flow's price, and `isPriceLocked` holds the card
        // and the Confirm button until it lands
        // (booking_payable_total.dart).
        //
        // This used to be a soft failure emitting `initial`, on the reasoning
        // that the summary stayed usable because the Confirm gate's
        // hasPayableAddon safety net still routed a paid wash through
        // addon-payment-init. That reasoning is gone with the fabricated price
        // it depended on: without a preview the card had no figures and
        // rendered SAR 0.00 for a payable wash, so "usable" meant submittable
        // against a price the customer was shown wrongly. With the gate in
        // place a silent `initial` would instead leave a placeholder and a
        // dead Confirm button with nothing on screen saying why — so the
        // failure is surfaced — and, since it is the same dead end the service
        // flow reaches when `/quote` fails, by the same means: `priceLoadFailed`
        // turns the summary's endless shimmer into an inline message with a
        // Retry that re-fires THIS call. Leaving and re-entering the flow used
        // to be the only way out of it.
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

    // First pass: collect all selected add-on lines with their GROSS charge.
    // Include both payable (chargedMinor > 0) and free (chargedMinor <= 0)
    // addons so that free/included addons are presented in the summary view.
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

    // Second pass: WashAddonLine carries no per-line net — only the GROSS
    // chargedMinor — while the summary renders each add-on row at line.net and
    // the subtotal at breakdown.net. So we DISTRIBUTE the backend-provided
    // breakdown.netMinor across the gross add-on lines proportionally
    // (lineNet = chargedMinor * breakdown.net / breakdown.gross), absorbing the
    // rounding remainder into the last paid line so the rows sum EXACTLY to
    // breakdown.netMinor. Free addons receive exactly 0 net and gross.
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
        // No breakdown net to distribute (older payload / single-line edge) —
        // fall back to the gross charge so the row still shows a sane amount.
        lineNet = p.grossMinor;
      } else if (i == lastPaidIndex) {
        // Last paid line absorbs the rounding remainder → Σ net == breakdown.netMinor.
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

  /// Pay-before-create step 4 (spec §4.2): the SDK returned a verified `paid`
  /// payment; create the booking with idempotency `booking-create:{id}`.
  ///
  /// The card is ALREADY charged when this runs, and refunds were removed
  /// platform-wide (Root CLAUDE.md §10): nothing on this platform returns
  /// money to a customer, so a failed create is ALWAYS
  /// [PaymentPhase.createUnconfirmed] — never a promise that the charge is
  /// coming back. A dropped connection or a timeout never reached an answer
  /// at all and the booking may well have been created; a 5xx rolled the
  /// transaction back; and a server rejection never compensates. Support is
  /// the only path back to that money, and the client must say so, not
  /// invent a refund.
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
