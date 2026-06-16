import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../../home/data/models/add_on_model.dart';
import 'day_time_model.dart';
import '../../../../core/enums/payment_method_enum.dart';
import 'quote_model.dart';

class BookingRequestModel {
  final ServiceModel? service;
  final MyCarModel? car;
  final AddressModel? address;
  final DateTime? date;
  final String? time;
  final List<AddOnModel> serviceAddOns;
  final List<String> workerNotes;
  final PaymentMethod? paymentMethod;
  final QuoteModel? quote;

  BookingRequestModel({
    this.service,
    this.car,
    this.address,
    this.date,
    this.time,
    this.serviceAddOns = const [],
    this.workerNotes = const [],
    this.paymentMethod,
    this.quote,
  });

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
    };
  }
}
