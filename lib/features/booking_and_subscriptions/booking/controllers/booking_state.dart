import 'package:equatable/equatable.dart';
import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../../../core/enums/payment_method_enum.dart';
import '../data/models/quote_model.dart';

enum BookingStatus { initial, loading, success, failure }

class BookingState extends Equatable {
  final BookingStatus status;
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

  const BookingState({
    this.status = BookingStatus.initial,
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
  });

  BookingState copyWith({
    BookingStatus? status,
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
    bool clearError = false,
  }) {
    return BookingState(
      status: status ?? (clearError ? BookingStatus.initial : this.status),
      selectedService: selectedService ?? this.selectedService,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedCar: selectedCar ?? this.selectedCar,
      selectedServiceIndices:
          selectedServiceIndices ?? this.selectedServiceIndices,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      bikerNotes: bikerNotes ?? this.bikerNotes,
      specialNoteText: specialNoteText ?? this.specialNoteText,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      quote: quote ?? this.quote,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
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
  ];
}
