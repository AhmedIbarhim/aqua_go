import '../../../../core/utils/saudi_wire_format.dart';
import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';

class RedeemGiftBookingRequestModel {
  final String giftCode;
  final AddressModel? address;
  final MyCarModel? car;
  final DateTime? date;
  final String? time;
  final DateTime? slotStart;

  RedeemGiftBookingRequestModel({
    required this.giftCode,
    this.address,
    this.car,
    this.date,
    this.time,
    this.slotStart,
  });

  Map<String, dynamic> toJson() {
    final addr = address;
    final isSavedAddress =
        addr?.id != null &&
        addr?.id != 'current_gps' &&
        addr?.id != 'custom_map';

    String scheduledAt = '';
    if (slotStart != null) {
      scheduledAt = toWireDateTime(slotStart!);
    } else if (date != null && time != null) {
      final parts = time!.split(':');
      if (parts.length >= 2) {
        final dt = DateTime(
          date!.year,
          date!.month,
          date!.day,
          int.tryParse(parts[0]) ?? 0,
          int.tryParse(parts[1]) ?? 0,
        );
        scheduledAt = toWireDateTime(dt);
      }
    }

    return {
      'giftCode': giftCode,
      if (isSavedAddress) 'savedAddressId': addr?.id,
      if (!isSavedAddress && addr != null) ...{
        'addressLabel': addr.details.isNotEmpty ? addr.details : addr.label,
        'lat': addr.lat,
        'lng': addr.lng,
        if (addr.arrivalNotes != null) 'addressArrivalNotes': addr.arrivalNotes,
      },
      'plateText': car?.plateNumber ?? '',
      'vehicleMake': car?.make ?? '',
      'vehicleModel': car?.model ?? '',
      'vehicleColor': car?.color ?? '',
      'vehicleYear': car?.modelYear ?? 2022,
      'type': 'SCHEDULED',
      'scheduledAt': scheduledAt,
      if (car?.id != null && car!.id.isNotEmpty) 'savedVehicleId': car!.id,
    };
  }
}
