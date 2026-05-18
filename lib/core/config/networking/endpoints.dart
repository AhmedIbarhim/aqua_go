abstract class Endpoints {
  static const String baseUrl = 'https://api.aquago.sa/api/customer';

  // Customer Auth Endpoints
  static const String customerSendOtp = '/login/otp';
  static const String customerVerifyOtp = '/login/otp/verify';
  static const String customerLogout = '/auth/logout';

  // Customer Profile Endpoints
  static const String customerMe = '/me';

  // Customer Email Verification
  static const String customerEmailVerifyRequest = '/me/email/verify/request';
  static const String customerEmailVerifyConfirm = '/me/email/verify/confirm';

  // Customer Vehicles Endpoints
  static const String customerVehicles = '/me/vehicles';
  static String customerVehicle(String vehicleId) => '/me/vehicles/$vehicleId';

  // Catalog / Services Endpoints
  static const String customerVehicleMakes = '/catalog/vehicle-makes';
  static String customerVehicleModels(String makeId) =>
      '/catalog/vehicle-makes/$makeId/models';
  static const String customerServices = '/services';

  // Customer Addresses Endpoints
  static const String customerAddresses = '/me/addresses';
  static String customerAddress(String addressId) => '/me/addresses/$addressId';

  // Customer Bookings & Quotes Endpoints
  static const String customerQuotes = '/quotes';
  static const String customerBookings = '/bookings';
  static String customerBookingDetail(String bookingId) =>
      '/bookings/$bookingId';
  static String customerCancelBooking(String bookingId) =>
      '/bookings/$bookingId/cancel';
  static String customerRescheduleBooking(String bookingId) =>
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
