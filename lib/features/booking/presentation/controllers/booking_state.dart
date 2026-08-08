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

  /// paid, and the create did not come back with an answer this client can
  /// assert anything about — a dropped connection, a timeout, a 5xx, or a
  /// server rejection. Refunds were removed platform-wide (Root CLAUDE.md
  /// §10): nothing on this platform returns money to a customer, so the
  /// client must never claim a charge is coming back. The booking may or may
  /// not exist and the charge may or may not have been returned by support
  /// yet, so nothing is asserted about either: the customer is told not to
  /// pay again, to check My Bookings, and to reach support if money left with
  /// no booking behind it.
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
  /// True when the call this flow prices from came back a FAILURE and left the
  /// summary with no price at all.
  ///
  /// The distinction this carries is "no price is coming" vs "no price YET",
  /// and `quote == null` alone cannot make it: both priced flows fire their
  /// price call from a post-frame callback, so an unanswered request and a
  /// failed one look identical on the state. Told apart they are two different
  /// screens — a shimmer and an inline retry — and conflated they were one
  /// endless shimmer with a dead Confirm button behind it, because nothing
  /// re-fires the call (see `resolvePriceDisplay`,
  /// booking_payable_total.dart).
  ///
  /// Set by BOTH price paths — `_priceAndPublish` / `_repriceAfter` for the
  /// service flow's `/quote`, and `fetchWashChargePreview` for the package
  /// flow's wash-charge preview — and cleared the moment either goes back out,
  /// so a retry in flight shows the shimmer rather than the error it is busy
  /// clearing.
  ///
  /// NOT the same fact as `status == BookingStatus.failure`, which every other
  /// failing call on this cubit also raises (submit, payment-init). Only a
  /// PRICE failure belongs here.
  final bool priceLoadFailed;
  /// IDs of addons that are INCLUDED in the subscription but whose free
  /// quota has been exhausted — selecting them requires payment.
  final Set<String> includedAddonIds;
  /// IDs of addons that are purely optional (always paid).
  final Set<String> optionalAddonIds;
  /// Current pay-before-create phase.
  final PaymentPhase paymentPhase;
  /// The payment-init result driving the SDK purchase (null when not paying).
  final PaymentInitModel? paymentInit;
  final String? giftCode;
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
  final String? rememberedOfferId;

  /// The offer's own title, in both languages, when the flow was started from a
  /// SERVICE offer card.
  final String? offerTitleAr;
  final String? offerTitleEn;

  /// The wash's VAT-INCLUSIVE gross LIST price in halala
  final int? offerListPriceMinor;

  /// The VAT-INCLUSIVE gross price the wash BECOMES through that offer
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
    this.priceLoadFailed = false,
    this.includedAddonIds = const {},
    this.optionalAddonIds = const {},
    this.paymentPhase = PaymentPhase.none,
    this.paymentInit,
    this.giftCode,
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
    bool? priceLoadFailed,
    Set<String>? includedAddonIds,
    Set<String>? optionalAddonIds,
    PaymentPhase? paymentPhase,
    PaymentInitModel? paymentInit,
    String? giftCode,
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
      priceLoadFailed: priceLoadFailed ?? this.priceLoadFailed,
      includedAddonIds: includedAddonIds ?? this.includedAddonIds,
      optionalAddonIds: optionalAddonIds ?? this.optionalAddonIds,
      paymentPhase: paymentPhase ?? this.paymentPhase,
      paymentInit: clearPaymentInit ? null : (paymentInit ?? this.paymentInit),
      giftCode: giftCode ?? this.giftCode,
      appliedPromoCode: clearPromo
          ? null
          : (appliedPromoCode ?? this.appliedPromoCode),
      appliedOfferId: (clearPromo || clearOfferId)
          ? null
          : (appliedOfferId ?? this.appliedOfferId),
      rememberedOfferId: clearRememberedOffer
          ? null
          : (rememberedOfferId ?? this.rememberedOfferId),
      offerTitleAr: offerTitleAr ?? this.offerTitleAr,
      offerTitleEn: offerTitleEn ?? this.offerTitleEn,
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
    priceLoadFailed,
    includedAddonIds,
    optionalAddonIds,
    paymentPhase,
    paymentInit,
    giftCode,
    appliedPromoCode,
    appliedOfferId,
    rememberedOfferId,
    offerTitleAr,
    offerTitleEn,
    offerListPriceMinor,
    offerTargetPriceMinor,
  ];
}
