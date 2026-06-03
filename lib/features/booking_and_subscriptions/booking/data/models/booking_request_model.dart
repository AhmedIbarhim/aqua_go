import '../../../../address/data/models/address_model.dart';
import '../../../../my_cars/data/models/my_car_model.dart';
import '../../../../home/data/models/service_model.dart';
import '../../../shared/add_on_model.dart';
import 'day_time_model.dart';
import '../../../../../core/enums/payment_method_enum.dart';
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
    String? scheduledAt;
    if (date != null && time != null) {
      scheduledAt = DayTimeModel(
        date: date!,
        rawTime: time!,
      ).toScheduledAtString();
    }

    final isSavedAddress =
        address?.id != null &&
        address?.id != 'current_gps' &&
        address?.id != 'custom_map';

    return {
      if (quote?.quoteId != null) 'quoteId': quote!.quoteId,
      if (isSavedAddress) 'savedAddressId': address?.id,
      if (!isSavedAddress && address != null) ...{
        'addressLabel': address?.label ?? '',
        'lat': address?.lat ?? 0.0,
        'lng': address?.lng ?? 0.0,
        if (address?.arrivalNotes != null)
          'addressArrivalNotes': address?.arrivalNotes,
      },
      'vehicles': [
        {
          if (car?.id != null) 'savedVehicleId': car?.id,
          if (car?.id == null && car != null) ...{
            'plateText': car?.plateNumber,
            if (car?.carBrand?.vehicleBrandName.nameEn != null)
              'vehicleMake': car?.carBrand?.vehicleBrandName.nameEn,
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
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
    };
  }

  // factory BookingModel.fromJson(Map<String, dynamic> json) {
  //   return BookingModel(
  //     service: ServiceModel.fromJson(json['service']),
  //     car: MyCarModel.fromJson(json['car']),
  //     address: AddressModel.fromJson(json['address']),
  //     date: DateTime.parse(json['date']),
  //     time: json['time'],
  //     additionalServices: (json['additionalServices'] as List)
  //         .map((e) => AddOnModel.fromJson(e))
  //         .toList(),
  //     bikerNotes: json['bikerNotes'] as List<String>,
  //     paymentMethod: PaymentMethodEnumExtension.fromString(
  //       json['paymentMethod'],
  //     ),
  //     quote: json['quote'] != null ? QuoteModel.fromJson(json['quote']) : null,
  //   );
  // }
}
