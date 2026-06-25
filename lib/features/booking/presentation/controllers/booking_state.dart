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

  /// paid but create failed → server auto-refund in progress.
  refundPending,
}

class BookingState extends Equatable {
  final BookingStatus status;
  final BookingFlowConfig flowConfig;
  final ServiceModel? selectedService;
  final AddressModel? selectedAddress;
  final MyCarModel? selectedCar;
  final Set<int> selectedServiceIndices;
  final DateTime? selectedDate;
  final String? selectedTime;
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
    this.selectedTime,
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
  });

  BookingState copyWith({
    BookingStatus? status,
    BookingFlowConfig? flowConfig,
    ServiceModel? selectedService,
    AddressModel? selectedAddress,
    MyCarModel? selectedCar,
    Set<int>? selectedServiceIndices,
    DateTime? selectedDate,
    String? selectedTime,
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
    bool clearSelectedDate = false,
    bool clearSelectedTime = false,
    bool clearError = false,
    bool clearPaymentInit = false,
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
      selectedTime: clearSelectedTime ? null : (selectedTime ?? this.selectedTime),
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
    selectedTime,
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
  ];
}
