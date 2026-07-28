import 'package:equatable/equatable.dart';
import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../../../core/enums/payment_method_enum.dart';
import '../../data/models/quote_model.dart';
import '../../data/models/payment_init_model.dart';
import '../../data/models/availability_response_model.dart';
import '../../domain/configs/booking_flow_config.dart';
import '../../../my_bookings/data/models/booking_response_model/booking_response_model.dart';

enum BookingStatus { initial, loading, success, failure }

/// The on-device pay-before-create phase (spec §10). `none` is the resting
/// state outside a payment attempt.
enum PaymentPhase {
  none,

  /// payment-init in flight (re-validate quote + soft-hold slot).
  initiated,

  /// the verified-paid payment is being sent to create the row.
  verifying,

  /// server is creating the booking after a verified payment.
  paidCreating,

  /// card declined / payment failed — retry in place.
  declined,

  /// user dismissed the SDK sheet.
  cancelled,

  /// paid, and the server ANSWERED with one of the rejections that refunds the
  /// charge as part of its contract (see `refund_evidence.dart`). The money is
  /// known to be coming back and the customer is told so.
  refundPending,

  /// paid, and the create did not come back with an answer this client can read
  /// as a refund — a dropped connection, a timeout, a 5xx, or a rejection that
  /// runs no compensation. The booking may or may not exist and the charge may
  /// or may not have been returned yet, so nothing is asserted about either:
  /// the customer is told not to pay again and to check My Bookings.
  createUnconfirmed,
}

class BookingState extends Equatable {
  final BookingStatus status;
  final BookingFlowConfig flowConfig;
  final ServiceModel? selectedService;
  final AddressModel? selectedAddress;
  final MyCarModel? selectedCar;
  final Set<int> selectedServiceIndices;
  final DateTime? selectedDate;
  /// The availability slot the customer picked, carried as the slot's own
  /// `start` [DateTime]. Never a display string: the wire `scheduledAt` is
  /// built from this value, so no localised label is ever re-parsed.
  final DateTime? selectedSlotStart;
  final Set<String> bikerNotes;
  final String specialNoteText;
  final PaymentMethod? paymentMethod;
  final QuoteModel? quote;
  final String? errorMessage;
  final List<AvailabilitySlot> availabilitySlots;
  final bool isAvailabilityLoading;
  final BookingResponseModel? createdBooking;
  final String? subscriptionId;
  final String? washId;
  /// The package's included (bundled) services resolved to full [ServiceModel]s
  /// via the services catalog. Only populated in [BookingFlowType.package].
  final List<ServiceModel> packageServices;
  /// The single included service the customer picked for this wash. Its [id]
  /// is sent to the backend as the wash service. Only used in the package flow.
  final ServiceModel? selectedPackageService;
  /// True when resolving the package's bundled services against the catalog
  /// failed. Lets the picker surface an inline error + retry instead of being
  /// silently hidden (which would let a wash submit with serviceId=null).
  final bool packageServicesLoadFailed;
  /// True while the bundled-services resolve is in flight.
  final bool packageServicesLoading;
  /// IDs of addons that are INCLUDED in the subscription but whose free
  /// quota has been exhausted — selecting them requires payment.
  final Set<String> includedAddonIds;
  /// IDs of addons that are purely optional (always paid).
  final Set<String> optionalAddonIds;
  /// Current pay-before-create phase.
  final PaymentPhase paymentPhase;
  /// The payment-init result driving the SDK purchase (null when not paying).
  final PaymentInitModel? paymentInit;
  /// The promo code the CURRENT [quote] was priced with, as the server
  /// normalised it (always upper case), or null when none applies. Lives here
  /// rather than in the summary route's `State` so it survives a pop back to
  /// the details screen and forward again — the quote it belongs to survives,
  /// so the chip that announces it must too.
  final String? appliedPromoCode;
  /// The merchandising offer the applied code came from, or null when the
  /// customer typed the code in. Sent to booking-create for redemption
  /// attribution; two live offers may link one code, so the code alone cannot
  /// say which offer drove the sale.
  final String? appliedOfferId;

  /// The offer this flow applied at least once, whether or not it is what
  /// prices the order NOW.
  ///
  /// [appliedOfferId] answers "which offer is this quote priced with", and it
  /// is rightly dropped the moment a quote comes back that the offer did not
  /// drive — `promo_redemptions.offer_id` is the whole of the sale attribution.
  /// That left no record at all that an offer had ever been in play, so a typed
  /// code applied over a live offer DESTROYED it for the session: removing the
  /// typed code could not bring it back, and the customer's only route to the
  /// deal they had accepted was to leave the flow and find the offer again.
  ///
  /// This is that record. It survives BOTH ways an offer stops pricing the
  /// order — the customer removes it, or a typed code supersedes it — which is
  /// the entire point, and it drives the summary's re-apply affordance.
  ///
  /// It is dropped ONLY when the server SETTLES the offer's fate against it:
  /// the cap is consumed, the campaign is over, the customer is ineligible. A
  /// transport failure decides nothing and drops nothing, exactly as it does
  /// for [offerListPriceMinor] / [offerTargetPriceMinor] — see
  /// `BookingCubit._isPromoVerdict`. A flow restart ([BookingCubit.initBooking])
  /// and a completed booking drop it too: it describes THIS booking.
  final String? rememberedOfferId;

  /// The offer's own title, in both languages, when the flow was started from a
  /// SERVICE offer card. Both are carried rather than one pre-localised string
  /// so a language switch mid-flow renames the card with everything else.
  /// Empty / null when the flow did not come through an offer, which is what
  /// puts the re-apply card on its generic copy.
  final String? offerTitleAr;
  final String? offerTitleEn;

  /// The wash's VAT-INCLUSIVE gross LIST price in halala, as the SERVICE offer
  /// the customer came through stated it. Null when the booking did not start
  /// from an offer.
  ///
  /// Display only, and a SERVER figure carried verbatim — never recomputed and
  /// never used to price anything. It exists so the details screen can strike
  /// it through beside the offer price (owner decision D-4).
  final int? offerListPriceMinor;

  /// The VAT-INCLUSIVE gross price the wash BECOMES through that offer, in
  /// halala. Null for a booking with no offer AND for a SHORTCUT offer, which
  /// carries no deal at all — 0 on the wire means "no deal", never "free", so
  /// it is normalised to null on the way in rather than rendered as 0.00.
  final int? offerTargetPriceMinor;

  const BookingState({
    this.status = BookingStatus.initial,
    this.flowConfig = const BookingFlowConfig(
      flowType: BookingFlowType.service,
    ),
    this.selectedService,
    this.selectedAddress,
    this.selectedCar,
    this.selectedServiceIndices = const {},
    this.selectedDate,
    this.selectedSlotStart,
    this.bikerNotes = const {},
    this.specialNoteText = '',
    this.paymentMethod,
    this.quote,
    this.errorMessage,
    this.availabilitySlots = const [],
    this.isAvailabilityLoading = false,
    this.createdBooking,
    this.subscriptionId,
    this.washId,
    this.packageServices = const [],
    this.selectedPackageService,
    this.packageServicesLoadFailed = false,
    this.packageServicesLoading = false,
    this.includedAddonIds = const {},
    this.optionalAddonIds = const {},
    this.paymentPhase = PaymentPhase.none,
    this.paymentInit,
    this.appliedPromoCode,
    this.appliedOfferId,
    this.rememberedOfferId,
    this.offerTitleAr,
    this.offerTitleEn,
    this.offerListPriceMinor,
    this.offerTargetPriceMinor,
  });

  BookingState copyWith({
    BookingStatus? status,
    BookingFlowConfig? flowConfig,
    ServiceModel? selectedService,
    AddressModel? selectedAddress,
    MyCarModel? selectedCar,
    Set<int>? selectedServiceIndices,
    DateTime? selectedDate,
    DateTime? selectedSlotStart,
    Set<String>? bikerNotes,
    String? specialNoteText,
    PaymentMethod? paymentMethod,
    QuoteModel? quote,
    String? errorMessage,
    List<AvailabilitySlot>? availabilitySlots,
    bool? isAvailabilityLoading,
    BookingResponseModel? createdBooking,
    String? subscriptionId,
    String? washId,
    List<ServiceModel>? packageServices,
    ServiceModel? selectedPackageService,
    bool? packageServicesLoadFailed,
    bool? packageServicesLoading,
    Set<String>? includedAddonIds,
    Set<String>? optionalAddonIds,
    PaymentPhase? paymentPhase,
    PaymentInitModel? paymentInit,
    String? appliedPromoCode,
    String? appliedOfferId,
    String? rememberedOfferId,
    String? offerTitleAr,
    String? offerTitleEn,
    int? offerListPriceMinor,
    int? offerTargetPriceMinor,
    bool clearSelectedDate = false,
    bool clearSelectedSlotStart = false,
    bool clearError = false,
    bool clearPaymentInit = false,
    bool clearPromo = false,
    bool clearOfferId = false,
    bool clearOfferPrices = false,
    bool clearRememberedOffer = false,
  }) {
    return BookingState(
      status: status ?? (clearError ? BookingStatus.initial : this.status),
      flowConfig: flowConfig ?? this.flowConfig,
      selectedService: selectedService ?? this.selectedService,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedCar: selectedCar ?? this.selectedCar,
      selectedServiceIndices:
          selectedServiceIndices ?? this.selectedServiceIndices,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      selectedSlotStart: clearSelectedSlotStart
          ? null
          : (selectedSlotStart ?? this.selectedSlotStart),
      bikerNotes: bikerNotes ?? this.bikerNotes,
      specialNoteText: specialNoteText ?? this.specialNoteText,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      quote: quote ?? this.quote,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      availabilitySlots: availabilitySlots ?? this.availabilitySlots,
      isAvailabilityLoading:
          isAvailabilityLoading ?? this.isAvailabilityLoading,
      createdBooking: createdBooking ?? this.createdBooking,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      washId: washId ?? this.washId,
      packageServices: packageServices ?? this.packageServices,
      selectedPackageService:
          selectedPackageService ?? this.selectedPackageService,
      packageServicesLoadFailed:
          packageServicesLoadFailed ?? this.packageServicesLoadFailed,
      packageServicesLoading:
          packageServicesLoading ?? this.packageServicesLoading,
      includedAddonIds: includedAddonIds ?? this.includedAddonIds,
      optionalAddonIds: optionalAddonIds ?? this.optionalAddonIds,
      paymentPhase: paymentPhase ?? this.paymentPhase,
      paymentInit: clearPaymentInit ? null : (paymentInit ?? this.paymentInit),
      // The code and the offer it came from are one fact — a quote priced
      // without a promo clears both, so a dropped code can never leave the
      // offer id behind to be stamped on a booking it did not drive.
      //
      // [clearOfferId] covers the other half: a quote priced WITH a code but
      // with no offer behind it (the customer typed a code over a live offer).
      // Without an explicit flag the `??` below would keep the previous offer
      // id and attribute the sale to an offer the customer never came through —
      // `offer_id` on the redemption row is the only attribution there is.
      appliedPromoCode: clearPromo
          ? null
          : (appliedPromoCode ?? this.appliedPromoCode),
      appliedOfferId: (clearPromo || clearOfferId)
          ? null
          : (appliedOfferId ?? this.appliedOfferId),
      // Deliberately NOT tied to clearPromo/clearOfferId — the two flags above
      // say "this quote was not priced by that offer", which is exactly the
      // moment this field has to survive. Only [clearRememberedOffer] drops it,
      // and only a caller holding the server's REFUSAL of the offer sets that.
      rememberedOfferId: clearRememberedOffer
          ? null
          : (rememberedOfferId ?? this.rememberedOfferId),
      offerTitleAr: offerTitleAr ?? this.offerTitleAr,
      offerTitleEn: offerTitleEn ?? this.offerTitleEn,
      // Deliberately NOT tied to clearPromo/clearOfferId. These two are what
      // the offer CARD promised, not what the current quote was priced with:
      // the details screen quotes bare on purpose (§6.93's mechanism), and
      // clearing them alongside the applied code would blank the very figures
      // D-4 exists to keep on screen.
      //
      // [clearOfferPrices] is the ONE case that does drop them, and it is a
      // different fact: the server was ASKED for the offer and REFUSED it (cap
      // consumed, campaign over, the customer ineligible — UCC23 A3). The card
      // no longer promises anything, so keeping the pair left the customer
      // reading "175.00 struck through, then 35.00" on details and being
      // charged 115.00 at the summary — the step-change D-4 exists to remove,
      // pointing the wrong way. It is a FLAG rather than a null argument for
      // the same reason [clearPromo] is: `??` cannot express "set to null".
      // Never set from the bare display re-quote, which says nothing about the
      // offer's fate.
      offerListPriceMinor: clearOfferPrices
          ? null
          : (offerListPriceMinor ?? this.offerListPriceMinor),
      offerTargetPriceMinor: clearOfferPrices
          ? null
          : (offerTargetPriceMinor ?? this.offerTargetPriceMinor),
    );
  }

  @override
  List<Object?> get props => [
    status,
    flowConfig,
    selectedService,
    selectedAddress,
    selectedCar,
    selectedServiceIndices,
    selectedDate,
    selectedSlotStart,
    bikerNotes,
    specialNoteText,
    paymentMethod,
    quote,
    errorMessage,
    availabilitySlots,
    isAvailabilityLoading,
    createdBooking,
    subscriptionId,
    washId,
    packageServices,
    selectedPackageService,
    packageServicesLoadFailed,
    packageServicesLoading,
    includedAddonIds,
    optionalAddonIds,
    paymentPhase,
    paymentInit,
    appliedPromoCode,
    appliedOfferId,
    rememberedOfferId,
    offerTitleAr,
    offerTitleEn,
    offerListPriceMinor,
    offerTargetPriceMinor,
  ];
}
