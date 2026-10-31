import '../../address/data/models/address_model.dart';
import '../../home/data/models/add_on_model.dart';
import '../../home/data/models/service_model.dart';
import '../../my_cars/data/models/my_car_model.dart';
import '../../../core/enums/payment_method_enum.dart';
import '../data/models/quote_model.dart';

/// Everything a submit strategy may need, gathered from the booking flow's
/// selection, pricing and payment at the moment of submitting.
class BookingSubmission {
  const BookingSubmission({
    this.selectedService,
    this.selectedAddons = const [],
    this.selectedCar,
    this.selectedAddress,
    this.selectedSlotStart,
    this.selectedPackageService,
    this.bikerNotes = const {},
    this.specialNoteText = '',
    this.paymentMethod,
    this.quote,
    this.appliedOfferId,
    this.holdToken,
    this.subscriptionId,
    this.washId,
    this.giftCode,
  });

  final ServiceModel? selectedService;
  final List<AddOnModel> selectedAddons;
  final MyCarModel? selectedCar;
  final AddressModel? selectedAddress;
  final DateTime? selectedSlotStart;
  final ServiceModel? selectedPackageService;
  final Set<String> bikerNotes;
  final String specialNoteText;
  final PaymentMethod? paymentMethod;
  final QuoteModel? quote;
  final String? appliedOfferId;
  final String? holdToken;
  final String? subscriptionId;
  final String? washId;
  final String? giftCode;
}
