import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import 'additional_service_model.dart';

class BookingModel {
  final ServiceModel? service;
  final MyCarModel? car;
  final AddressModel? address;
  final DateTime? date;
  final String? time;
  final List<AdditionalServiceModel> additionalServices;
  final List<String> bikerNotes;
  final String? paymentMethod;

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
      final String formattedMonth = date!.month.toString().padLeft(2, '0');
      final String formattedDay = date!.day.toString().padLeft(2, '0');
      final String formattedTime = time!.contains(' ')
          ? time!.split(' ').first
          : time!;
      scheduledAt =
          '${date!.year}-$formattedMonth-${formattedDay}T$formattedTime:00Z';
    }

    return {
      'savedAddressId': address?.id == 'current_gps' ? null : address?.id,
      'addressLabel': address?.label,
      'lat': address?.lat,
      'lng': address?.lng,
      'addressArrivalNotes': '',
      'plateText': car?.plateNumber,
      'vehicleMake': car?.carBrand?.vehicleBrandName.nameEn,
      'vehicleModel': car?.carModel?.vehicleModelName.nameEn,
      'vehicleColor': car?.color,
      'type': 'SCHEDULED',
      'scheduledAt': scheduledAt,
      'savedVehicleId': car?.id,
      'workerNotes': bikerNotes,
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
      paymentMethod: json['paymentMethod'],
    );
  }
}
