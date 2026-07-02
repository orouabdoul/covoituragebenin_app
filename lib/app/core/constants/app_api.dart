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
  static const String driverPaymentHistory = '/driver/payment-history';
  static const String driverStats          = '/driver/stats';

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
}