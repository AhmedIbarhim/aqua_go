import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import 'additional_service_model.dart';
import 'day_time_model.dart';
import '../../../../core/enums/payment_method_enum.dart';

class BookingModel {
  final ServiceModel? service;
  final MyCarModel? car;
  final AddressModel? address;
  final DateTime? date;
  final String? time;
  final List<AdditionalServiceModel> additionalServices;
  final List<String> bikerNotes;
  final PaymentMethod? paymentMethod;

  BookingModel({
    this.service,
    this.car,
    this.address,
    this.date,
    this.time,
    this.additionalServices = const [],
    this.bikerNotes = const [],
    this.paymentMethod,
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

    return {
      if (address?.id != null && address?.id != 'current_gps')
        'savedAddressId': address?.id,
      'addressLabel': address?.label,
      'lat': address?.lat,
      'lng': address?.lng,
      if (address?.arrivalNotes != null)
        'addressArrivalNotes': address?.arrivalNotes,
      'plateText': car?.plateNumber,
      'vehicleMake': car?.carBrand?.vehicleBrandName.nameEn,
      'vehicleModel': car?.carModel?.vehicleModelName.nameEn,
      'vehicleColor': car?.color,
      'vehicleYear': car?.modelYear,
      'type': 'SCHEDULED',
      'scheduledAt': scheduledAt,
      if (car?.id != null) 'savedVehicleId': car?.id,
      'workerNotes': bikerNotes,
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      service: ServiceModel.fromJson(json['service']),
      car: MyCarModel.fromJson(json['car']),
      address: AddressModel.fromJson(json['address']),
      date: DateTime.parse(json['date']),
      time: json['time'],
      additionalServices: (json['additionalServices'] as List)
          .map((e) => AdditionalServiceModel.fromJson(e))
          .toList(),
      bikerNotes: json['bikerNotes'] as List<String>,
      paymentMethod: PaymentMethodEnumExtension.fromString(
        json['paymentMethod'],
      ),
    );
  }
}
