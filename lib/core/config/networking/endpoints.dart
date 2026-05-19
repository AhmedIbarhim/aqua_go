abstract class Endpoints {
  static const String baseUrl = 'https://api.aquago.sa/api/customer';

  // Customer Auth Endpoints
  static const String sendOtp = '/login/otp';
  static const String verifyOtp = '/login/otp/verify';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/token/refresh';

  // Customer Profile Endpoints
  static const String customerMe = '/me';

  // Customer Email Verification
  static const String verifyRequest = '/me/email/verify/request';
  static const String emailVerifyConfirm = '/me/email/verify/confirm';

  // Customer Vehicles Endpoints
  static const String myVehicles = '/me/vehicles';
  static String myVehicle(String vehicleId) => '/me/vehicles/$vehicleId';

  // Catalog / Services Endpoints
  static const String vehicleBrands = '/catalog/vehicle-makes';
  static String vehicleModels(String brandId) =>
      '/catalog/vehicle-makes/$brandId/models';

  static const String services = '/services';

  // Customer Addresses Endpoints
  static const String myAdresses = '/me/addresses';
  static String myAddress(String addressId) => '/me/addresses/$addressId';

  // Customer Bookings & Quotes Endpoints
  static const String quotes = '/quotes';
  static const String bookings = '/bookings';
  static String bookingDetail(String bookingId) => '/bookings/$bookingId';
  static String cancelBooking(String bookingId) =>
      '/bookings/$bookingId/cancel';
  static String rescheduleBooking(String bookingId) =>
      '/bookings/$bookingId/reschedule';

  // Google Maps Endpoints
  static const String googleMapsAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String googleMapsPlaceDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const String googleMapsGeocodeUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  static String nameAvatar(String? userName) =>
      'https://ui-avatars.com/api/?name=$userName&background=00D5DD&color=fff';
}
