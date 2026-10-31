import 'package:equatable/equatable.dart';
import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/add_on_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../../../core/enums/payment_method_enum.dart';
import '../../data/models/availability_response_model.dart';
import '../../domain/configs/booking_flow_config.dart';

enum BookingStatus { initial, loading, success, failure }

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
  final String? errorMessage;
  final List<AvailabilitySlot> availabilitySlots;
  final bool isAvailabilityLoading;
  final String? subscriptionId;
  final String? washId;

  final List<ServiceModel> packageServices;

  final ServiceModel? selectedPackageService;

  final bool packageServicesLoadFailed;

  /// IDs of addons that are INCLUDED in the subscription but whose free
  /// quota has been exhausted — selecting them requires payment.
  final Set<String> includedAddonIds;

  /// IDs of addons that are purely optional (always paid).
  final Set<String> optionalAddonIds;

  final String? giftCode;

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
    this.errorMessage,
    this.availabilitySlots = const [],
    this.isAvailabilityLoading = false,
    this.subscriptionId,
    this.washId,
    this.packageServices = const [],
    this.selectedPackageService,
    this.packageServicesLoadFailed = false,
    this.includedAddonIds = const {},
    this.optionalAddonIds = const {},
    this.giftCode,
  });

  /// A price needs both what is being booked and where.
  bool get canPrice => selectedService != null && selectedAddress != null;

  List<AddOnModel> get selectedAddons {
    final addons = selectedService?.addons ?? const [];
    return selectedServiceIndices
        .where((idx) => idx < addons.length)
        .map((idx) => addons[idx])
        .toList();
  }

  List<String> get selectedAddonIds =>
      selectedAddons.map((a) => a.id).whereType<String>().toList();

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
    String? errorMessage,
    List<AvailabilitySlot>? availabilitySlots,
    bool? isAvailabilityLoading,
    String? subscriptionId,
    String? washId,
    List<ServiceModel>? packageServices,
    ServiceModel? selectedPackageService,
    bool? packageServicesLoadFailed,
    Set<String>? includedAddonIds,
    Set<String>? optionalAddonIds,
    String? giftCode,
    bool clearSelectedDate = false,
    bool clearSelectedSlotStart = false,
    bool clearError = false,
  }) {
    return BookingState(
      // Clearing an error settles the screen, but a request still in flight
      // owns the status until it lands.
      status:
          status ??
          (clearError && this.status != BookingStatus.loading
              ? BookingStatus.initial
              : this.status),
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
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      availabilitySlots: availabilitySlots ?? this.availabilitySlots,
      isAvailabilityLoading:
          isAvailabilityLoading ?? this.isAvailabilityLoading,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      washId: washId ?? this.washId,
      packageServices: packageServices ?? this.packageServices,
      selectedPackageService:
          selectedPackageService ?? this.selectedPackageService,
      packageServicesLoadFailed:
          packageServicesLoadFailed ?? this.packageServicesLoadFailed,
      includedAddonIds: includedAddonIds ?? this.includedAddonIds,
      optionalAddonIds: optionalAddonIds ?? this.optionalAddonIds,
      giftCode: giftCode ?? this.giftCode,
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
    errorMessage,
    availabilitySlots,
    isAvailabilityLoading,
    subscriptionId,
    washId,
    packageServices,
    selectedPackageService,
    packageServicesLoadFailed,
    includedAddonIds,
    optionalAddonIds,
    giftCode,
  ];
}
