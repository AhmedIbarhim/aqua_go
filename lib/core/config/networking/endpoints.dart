abstract class Endpoints {
  static const String googleMapsAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String googleMapsPlaceDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const String googleMapsGeocodeUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  static String nameAvatar(String? userName) =>
      'https://ui-avatars.com/api/?name=$userName&background=00D5DD&color=fff';
}
