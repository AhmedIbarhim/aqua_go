import 'package:equatable/equatable.dart';
import '../../../adress/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../widgets/payment_method_selection.dart';

enum BookingStatus { initial, loading, success, failure }

class BookingState extends Equatable {
  final BookingStatus status;
  final AddressModel? selectedAddress;
  final MyCarModel? selectedCar;
  final Set<int> selectedServiceIndices;
  final DateTime? selectedDate;
  final String? selectedTime;
  final Set<String> bikerNotes;
  final PaymentMethod? paymentMethod;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStatus.initial,
    this.selectedAddress,
    this.selectedCar,
    this.selectedServiceIndices = const {},
    this.selectedDate,
    this.selectedTime,
    this.bikerNotes = const {},
    this.paymentMethod,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStatus? status,
    AddressModel? selectedAddress,
    MyCarModel? selectedCar,
    Set<int>? selectedServiceIndices,
    DateTime? selectedDate,
    String? selectedTime,
    Set<String>? bikerNotes,
    PaymentMethod? paymentMethod,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedCar: selectedCar ?? this.selectedCar,
      selectedServiceIndices: selectedServiceIndices ?? this.selectedServiceIndices,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      bikerNotes: bikerNotes ?? this.bikerNotes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedAddress,
        selectedCar,
        selectedServiceIndices,
        selectedDate,
        selectedTime,
        bikerNotes,
        paymentMethod,
        errorMessage,
      ];
}
