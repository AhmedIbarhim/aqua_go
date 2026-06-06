abstract class Endpoints {
  static const String baseUrl = 'https://api.aquago.sa/api/customer/';

  //  Auth Endpoints
  static const String sendOtp = 'login/otp';
  static const String verifyOtp = 'login/otp/verify';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/token/refresh';

  //  Profile & Account Endpoints
  static const String customerMe = 'me';
  static const String deletionRequest = 'me/deletion-request';
  static const String dataExport = 'me/data-export';
  static const String profileImagePresign = 'me/profile-image/presign';
  static const String profileImageConfirm = 'me/profile-image/confirm';

  //  Email Verification
  static const String verifyRequest = 'me/email/verify/request';
  static const String emailVerifyConfirm = 'me/email/verify/confirm';

  //  Vehicles Endpoints
  static const String myVehicles = 'me/vehicles';
  static String myVehicle(String vehicleId) => 'me/vehicles/$vehicleId';
  static const String vehicleMakes = 'catalog/vehicle-makes';
  static String vehicleModels(String makeId) =>
      'catalog/vehicle-makes/$makeId/models';
  static String makeLogo(String makeId) => 'catalog/vehicle-makes/$makeId/logo';
  static String catalogPackageImage(String packageId) =>
      'catalog/packages/$packageId/image';
  static String vehicleMakeDetails(String makeId) =>
      'catalog/vehicle-makes/$makeId';
  static String vehicleModelDetails(String modelId) =>
      'catalog/vehicle-models/$modelId';

  static const String services = 'services';
  static String addonDetail(String addonId) => 'add-ons/$addonId';

  //  Addresses Endpoints
  static const String myAddresses = 'me/addresses';
  static String myAddress(String addressId) => 'me/addresses/$addressId';

  //  Bookings & Quotes Endpoints
  static const String quotes = 'quotes';
  static const String bookings = 'bookings';
  static String bookingDetail(String bookingId) => 'bookings/$bookingId';
  static String cancelBooking(String bookingId) => 'bookings/$bookingId/cancel';
  static String rescheduleBooking(String bookingId) =>
      'bookings/$bookingId/reschedule';
  static String scheduleBooking(String bookingId) =>
      'bookings/$bookingId/schedule';
  static String rateBooking(String bookingId) => 'bookings/$bookingId/rating';
  static String editBookingLogistics(String bookingId) =>
      'bookings/$bookingId/edit';
  static String tipBooking(String bookingId) => 'bookings/$bookingId/tip';

  //  Banners Endpoints
  static const String banners = 'banners';

  //  Geo & Zone Coverage Endpoints
  static const String zoneCheck = 'geo/zone-check';
  static const String geoPlacesAutocomplete = 'geo/places/autocomplete';
  static String geoPlaceDetail(String placeId) => 'geo/places/$placeId';

  //  Packages & Subscriptions Endpoints
  static const String packages = 'subscription-packages';
  static const String subscriptions = 'subscriptions';
  static String subscriptionDetail(String subscriptionId) =>
      'subscriptions/$subscriptionId';
  static String cancelSubscription(String subscriptionId) =>
      'subscriptions/$subscriptionId/cancel';

  //  Availability Endpoints
  static const String availability = 'availability';
  static const String availabilityNow = 'availability/now';

  //  Notification Preferences Endpoints
  static const String notificationPreferences = 'me/notification-preferences';

  // Notification Inbox & Devices Endpoints
  static const String notifications = 'me/notifications';
  static const String readAllNotifications = 'me/notifications/read-all';
  static const String unreadNotificationsCount =
      'me/notifications/unread-count';
  static String readNotification(String notificationId) =>
      'me/notifications/$notificationId/read';
  static const String registerDevice = 'me/devices';
  static String deregisterDevice(String deviceId) => 'me/devices/$deviceId';

  //  Consent Endpoints
  static const String consents = 'me/consents';

  // Customer Policies Endpoints
  static String policy(String type) => 'policies/$type';

  // Customer Complaints Endpoints
  static const String complaints = 'complaints';
  static String complaintDetail(String complaintId) =>
      'complaints/$complaintId';
  static String complaintPhotoPresign(String complaintId) =>
      'complaints/$complaintId/photos/presign';

  // Wallet Endpoints
  static const String wallet = 'me/wallet';
  static const String walletAutoTopup = 'me/wallet/auto-topup';
  static const String walletTopup = 'me/wallet/topup';
  static const String walletLedger = 'me/wallet/ledger';

  // Saved Cards Endpoints
  static const String savedCards = 'me/saved-cards';
  static String deleteSavedCard(String cardId) => 'me/saved-cards/$cardId';
  static String setDefaultSavedCard(String cardId) =>
      'me/saved-cards/$cardId/set-default';

  // Gift Themes & Gifts Endpoints
  static const String giftThemes = 'gift-themes';
  static const String gifts = 'gifts';
  static String giftDetail(String giftId) => 'gifts/$giftId';
  static String cancelGift(String giftId) => 'gifts/$giftId/cancel';
  static const String redeemGift = 'gifts/redeem';

  // Promos Endpoints
  static const String validatePromo = 'promos/validate';
  static String promoDetail(String code) => 'promos/$code';

  // FAQs Endpoints
  static const String faqs = 'faqs';
  static const String searchFaqs = 'faqs/search';
  static String voteFaqHelpful(String faqId) => 'faqs/$faqId/helpful';

  // Chat Endpoints
  static const String chatThreads = 'chat/threads';
  static String readChatThread(String threadId) =>
      'chat/threads/$threadId/read';
  static String chatMessages(String threadId) =>
      'chat/threads/$threadId/messages';
  static String chatAttachmentPresign(String threadId) =>
      'chat/threads/$threadId/messages/attachment/presign';
  static String reportChatMessage(String messageId) =>
      'chat/messages/$messageId/report';

  // External Google Maps Endpoints (Legacy Direct Calls)
  static const String googleMapsAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String googleMapsPlaceDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const String googleMapsGeocodeUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  static String nameAvatar(String? userName) =>
      'https://ui-avatars.com/api/?name=$userName&background=00D5DD&color=fff';
}
