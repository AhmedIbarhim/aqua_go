abstract class Endpoints {
  static const String baseUrl = 'https://api.aquago.sa';

  // Customer Auth Endpoints
  static const String customerSendOtp = '/api/customer/login/otp';
  static const String customerVerifyOtp = '/api/customer/login/otp/verify';
  static const String customerLogout = '/api/customer/auth/logout';

  // Customer Profile Endpoints
  static const String customerMe = '/api/customer/me';
  
  // Customer Email Verification
  static const String customerEmailVerifyRequest = '/api/customer/me/email/verify/request';
  static const String customerEmailVerifyConfirm = '/api/customer/me/email/verify/confirm';

  static const String googleMapsAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String googleMapsPlaceDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const String googleMapsGeocodeUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  static String nameAvatar(String? userName) =>
      'https://ui-avatars.com/api/?name=$userName&background=00D5DD&color=fff';
}

