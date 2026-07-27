import '../../../address/data/models/address_model.dart';
import '../../../my_cars/data/models/my_car_model.dart';
import '../../../home/data/models/service_model.dart';
import '../../../home/data/models/add_on_model.dart';
import '../../../../core/enums/payment_method_enum.dart';
import '../../../../core/utils/saudi_wire_format.dart';
import 'quote_model.dart';

class ServiceBookingRequestModel {
  final ServiceModel? service;
  final MyCarModel? car;
  final AddressModel? address;
  /// The picked availability slot's own `start` instant. Serialised verbatim
  /// as the bare Asia/Riyadh `scheduledAt` — no display string in between.
  final DateTime? slotStart;
  final List<AddOnModel> serviceAddOns;
  final List<String> workerNotes;
  final PaymentMethod? paymentMethod;
  final QuoteModel? quote;

  /// The Moyasar payment id returned by the on-device SDK purchase. The
  /// backend verifies this `paid` payment, then creates the booking
  /// (pay-before-create). Required on the create call.
  final String? moyasarPaymentId;

  /// The merchandising offer this booking came through — the SAME offerId the
  /// quote was priced with. Null for a manually typed code. Carried purely for
  /// redemption attribution (`promo.promo_redemptions.offer_id`): the discount
  /// itself is already frozen in the quote, and the server rejects a create
  /// whose offer resolves to a different code than the quote was priced with.
  final String? offerId;

  ServiceBookingRequestModel({
    this.service,
    this.car,
    this.address,
    this.slotStart,
    this.serviceAddOns = const [],
    this.workerNotes = const [],
    this.paymentMethod,
    this.quote,
    this.moyasarPaymentId,
    this.offerId,
  });

  ServiceBookingRequestModel copyWith({String? moyasarPaymentId}) {
    return ServiceBookingRequestModel(
      service: service,
      car: car,
      address: address,
      slotStart: slotStart,
      serviceAddOns: serviceAddOns,
      workerNotes: workerNotes,
      paymentMethod: paymentMethod,
      quote: quote,
      moyasarPaymentId: moyasarPaymentId ?? this.moyasarPaymentId,
      offerId: offerId,
    );
  }

  Map<String, dynamic> toJson() {
    final addr = address;
    final start = slotStart;
    final String? scheduledAt = start != null ? toWireDateTime(start) : null;

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
      if (moyasarPaymentId != null) 'moyasarPaymentId': moyasarPaymentId,
      if (offerId != null) 'offerId': offerId,
    };
  }
}
