import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../../home/data/models/add_on_model.dart';
import 'day_time_model.dart';
import '../../../../core/enums/payment_method_enum.dart';
import 'quote_model.dart';

class ServiceBookingRequestModel {
  final ServiceModel? service;
  final MyCarModel? car;
  final AddressModel? address;
  final DateTime? date;
  final String? time;
  final List<AddOnModel> serviceAddOns;
  final List<String> workerNotes;
  final PaymentMethod? paymentMethod;
  final QuoteModel? quote;

  /// The Moyasar payment id returned by the on-device SDK purchase. The
  /// backend verifies this `paid` payment, then creates the booking
  /// (pay-before-create). Required on the create call.
  final String? moyasarPaymentId;

  /// Soft slot-hold token returned by POST /api/customer/bookings/payment-init.
  final String? holdToken;

  ServiceBookingRequestModel({
    this.service,
    this.car,
    this.address,
    this.date,
    this.time,
    this.serviceAddOns = const [],
    this.workerNotes = const [],
    this.paymentMethod,
    this.quote,
    this.moyasarPaymentId,
    this.holdToken,
  });

  ServiceBookingRequestModel copyWith({
    String? moyasarPaymentId,
    String? holdToken,
  }) {
    return ServiceBookingRequestModel(
      service: service,
      car: car,
      address: address,
      date: date,
      time: time,
      serviceAddOns: serviceAddOns,
      workerNotes: workerNotes,
      paymentMethod: paymentMethod,
      quote: quote,
      moyasarPaymentId: moyasarPaymentId ?? this.moyasarPaymentId,
      holdToken: holdToken ?? this.holdToken,
    );
  }

  bool get isComplete =>
      service != null &&
      car != null &&
      address != null &&
      date != null &&
      time != null;

  Map<String, dynamic> toJson() {
    final addr = address;
    String? scheduledAt;
    if (date != null && time != null) {
      scheduledAt = DayTimeModel(
        date: date!,
        rawTime: time!,
      ).toScheduledAtString();
    }

    final isSavedAddress =
        addr?.id != null &&
        addr?.id != 'current_gps' &&
        addr?.id != 'custom_map';

    return {
      if (quote?.quoteId != null) 'quoteId': quote!.quoteId,
      if (isSavedAddress) ...{
        'savedAddressId': addr?.id,
        // 'addressLabel': addr?.details ?? '',
      },
      if (!isSavedAddress && addr != null) ...{
        'addressLabel': addr.details.isNotEmpty ? addr.details : addr.label,
        'lat': addr.lat,
        'lng': addr.lng,
        if (addr.arrivalNotes != null) 'addressArrivalNotes': addr.arrivalNotes,
      },
      'vehicles': [
        {
          if (car?.id != null) 'savedVehicleId': car?.id,
          if (car?.id == null && car != null) ...{
            'plateText': car?.plateNumber,
            if (car?.carMake?.vehicleMakeName.nameEn != null)
              'vehicleMake': car?.carMake?.vehicleMakeName.nameEn,
            if (car?.carModel?.vehicleModelName.nameEn != null)
              'vehicleModel': car?.carModel?.vehicleModelName.nameEn,
            'vehicleColor': car?.color,
            'vehicleYear': car?.modelYear,
          },
        },
      ],
      'type': 'SCHEDULED',
      'scheduledAt': ?scheduledAt,
      if (workerNotes.isNotEmpty) 'workerNotes': workerNotes,
      if (serviceAddOns.isNotEmpty)
        'addOns': serviceAddOns.map((e) => {'addonId': e.id}).toList(),
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
      'moyasarPaymentId': ?moyasarPaymentId,
      'holdToken': ?holdToken,
    };
  }
}
