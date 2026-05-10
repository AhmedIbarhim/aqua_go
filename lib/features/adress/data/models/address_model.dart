import 'location_model.dart';

class AddressModel {
  final String name;
  final String formattedAddress;
  final double lat;
  final double lng;

  AddressModel({
    required this.name,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  factory AddressModel.fromLocation(LocationModel location,
      {required String name}) {
    return AddressModel(
      name: name,
      formattedAddress: location.formattedAddress,
      lat: location.lat,
      lng: location.lng,
    );
  }
}
