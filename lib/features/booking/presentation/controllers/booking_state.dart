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

  final List<ServiceModel> packageServices;

  final ServiceModel? selectedPackageService;

  final bool packageServicesLoadFailed;

  /// True while the bundled-services resolve is in flight.
  final bool packageServicesLoading;

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

  final String? appliedPromoCode;

  final String? appliedOfferId;

  final String? rememberedOfferId;

  final String? offerTitleAr;
  final String? offerTitleEn;

  final int? offerListPriceMinor;

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
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
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
