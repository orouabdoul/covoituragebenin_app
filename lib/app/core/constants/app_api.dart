const String apiBaseUrl = 'https://minizon-api.onrender.com/api';

class AppApi {
  static const String baseUrl = apiBaseUrl;
  static const String roles = '/roles';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';

  // Bookings — conducteur
  static const String driverBookings = '/driver/bookings';
  static String bookingAccept(String uuid) => '/bookings/$uuid/accept';
  static String bookingReject(String uuid) => '/bookings/$uuid/reject';

  // Wallet / revenus — conducteur
  static const String driverPaymentHistory        = '/driver/payment-history';
  static const String driverPaymentHistoryReceipt = '/driver/payment-history/receipt';
  static const String driverStats                 = '/driver/stats';

  // Sécurité — conducteur
  static const String driverSafetySos       = '/driver/safety/sos';
  static const String driverSafetyIncidents = '/driver/safety/incidents';
  static const String driverSafetyContacts  = '/driver/safety/emergency-contacts';
  static String driverSafetyContact(String id) => '/driver/safety/emergency-contacts/$id';

  // Support — conducteur
  static const String driverSupportFaq     = '/driver/support/faq';
  static const String driverSupportTickets = '/driver/support/tickets';

  // Véhicules — conducteur
  static const String driverVehicles = '/driver/vehicles';
  static String driverVehicle(String uuid) => '/driver/vehicles/$uuid';

  // Retrait — conducteur
  static const String driverWallet   = '/driver/wallet';
  static const String driverWithdraw = '/driver/withdraw';

  // Dashboard / disponibilité — conducteur
  static const String driverDashboard    = '/driver/dashboard';
  static const String driverAvailability = '/driver/availability';

  // Profil — conducteur
  static const String driverProfile     = '/driver/profile';
  static const String driverPreferences = '/driver/preferences';

  // Trajets — conducteur
  static const String driverTrips = '/driver/trips';
  static const String driverTripPublish = '/driver/trip-publish';
  static String driverTripPassengers(String uuid) => '/driver/trips/$uuid/passengers';
  static String driverTripCancel(String uuid) => '/driver/trips/$uuid/cancel';
  static String driverTripDetail(String uuid) => '/driver/trips/$uuid';
  static String driverTripUpdate(String uuid) => '/driver/trips/$uuid';
  static String driverTripPreDeparture(String uuid) => '/driver/trips/$uuid/pre-departure';
  static String tripStart(String uuid) => '/trips/$uuid/start';
  static String driverTripEndSummary(String uuid) => '/driver/trips/$uuid/end-summary';
  static String tripEnd(String uuid) => '/trips/$uuid/end';

  // Notifications — conducteur
  static const String driverNotifications     = '/driver/notifications';
  static String driverNotificationRead(String id) => '/driver/notifications/$id/read';
  static const String driverNotificationsReadAll = '/driver/notifications/read-all';

  // Carte interactive — conducteur
  static String driverTripMap(String uuid) => '/driver/trips/$uuid/map';
  static String driverTripStopDone(String tripUuid, String bookingUuid) =>
      '/driver/trips/$tripUuid/stops/$bookingUuid/done';
  static String driverTripRecalculate(String uuid) => '/driver/trips/$uuid/recalculate';

  // Messagerie — conducteur
  static const String driverMessager = '/driver/messager';
  static String driverConversationThread(String uuid) => '/driver/conversations/$uuid/thread';
  static String conversationMessages(String uuid) => '/conversations/$uuid/messages';
  static String conversationRead(String uuid) => '/conversations/$uuid/read';

  // Avis — conducteur
  static const String driverReviews = '/driver/reviews';
  static String driverReviewReply(String uuid) => '/driver/reviews/$uuid/reply';
}
