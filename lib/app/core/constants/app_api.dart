const String apiBaseUrl = 'https://minizon-api.onrender.com/api';

class AppApi {
  static const String baseUrl = apiBaseUrl;
  static const String roles = '/roles';
  static const String sendOtp   = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String logout    = '/auth/logout';
  static const String me        = '/auth/me';

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

  // Support — passager
  static const String passengerSupportFaq     = '/passenger/support/faq';
  static const String passengerSupportTickets = '/passenger/support/tickets';

  // Remboursement — passager
  static String passengerRefundContext(String uuid) => '/passenger/bookings/$uuid/refund-context';
  static String passengerRefundSubmit(String uuid) => '/passenger/bookings/$uuid/refund';
  static const String passengerRefunds = '/passenger/refunds';

  // Sécurité — passager
  static const String passengerSafety          = '/passenger/safety';
  static const String passengerSafetySos       = '/passenger/safety/sos';
  static const String passengerSafetyTripShare = '/passenger/safety/trip-share';
  static const String passengerSafetyContacts  = '/passenger/safety/emergency-contacts';
  static String passengerSafetyContact(String id) => '/passenger/safety/emergency-contacts/$id';

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

  // Notifications — passager
  static const String passengerNotifications      = '/passenger/notifications';
  static String passengerNotificationRead(String id) => '/passenger/notifications/$id/read';
  static const String passengerNotificationsReadAll = '/passenger/notifications/read-all';
  static String passengerNotificationDelete(String id) => '/passenger/notifications/$id';

  // Carte interactive — conducteur
  static String driverTripMap(String uuid) => '/driver/trips/$uuid/map';
  static String driverTripStopDone(String tripUuid, String bookingUuid) =>
      '/driver/trips/$tripUuid/stops/$bookingUuid/done';
  static String driverTripRecalculate(String uuid) => '/driver/trips/$uuid/recalculate';

  // Dashboard / Profil / Avis / Stats / Trajets — passager
  static const String passengerHome        = '/passenger/home';
  static const String passengerProfile     = '/passenger/profile';
  static const String passengerStats       = '/passenger/stats';
  static const String passengerReviews     = '/passenger/reviews';
  static const String passengerTripHistory = '/passenger/trips/history';

  // Réservations — passager
  static String passengerTripConfirmationCtx(String uuid) => '/passenger/trips/$uuid/confirmation-context';
  static String passengerTripLiveTracking(String uuid) => '/passenger/trips/$uuid/live-tracking';
  static String passengerTripDetail(String uuid) => '/passenger/trips/$uuid/detail';
  static String passengerBookingSuccess(String uuid) => '/passenger/bookings/$uuid/success';
  static String passengerBookingApprovalStatus(String uuid) => '/passenger/bookings/$uuid/approval-status';
  static String passengerBookingTripConfirmationCtx(String uuid) => '/passenger/bookings/$uuid/trip-confirmation-context';
  static String passengerBookingConfirm(String uuid) => '/passenger/bookings/$uuid/confirm';
  static String passengerBookingReview(String uuid) => '/passenger/bookings/$uuid/review';
  static const String passengerReservationsList = '/passenger/reservations';
  static String passengerReservationInvoice(String uuid) => '/passenger/reservations/$uuid/invoice';
  static String createBooking(String tripUuid) => '/trips/$tripUuid/bookings';
  static String initiateBookingPayment(String bookingUuid) => '/bookings/$bookingUuid/pay';
  static String cancelBooking(String bookingUuid) => '/bookings/$bookingUuid/cancel';

  // Recherche — passager (public)
  static const String passengerSearch = '/passenger/search';

  // Messagerie — passager
  static const String passengerMessager = '/passenger/messager';
  static String passengerConversationThread(String uuid) => '/passenger/conversations/$uuid/thread';
  static String passengerConversationMessages(String uuid) => '/passenger/conversations/$uuid/messages';
  static String passengerConversationRead(String uuid) => '/passenger/conversations/$uuid/read';
  static String passengerBookingStartConversation(String bookingUuid) => '/passenger/bookings/$bookingUuid/conversation';
  static String passengerMessageDelete(String messageUuid) => '/passenger/messages/$messageUuid';
  static String passengerMessageEdit(String messageUuid) => '/passenger/messages/$messageUuid';

  // Messagerie — partagé (legacy, conservé pour compatibilité)
  static String bookingStartConversation(String bookingUuid) => '/bookings/$bookingUuid/conversation';

  // Messagerie — conducteur
  static const String driverMessager = '/driver/messager';
  static String driverConversationThread(String uuid) => '/driver/conversations/$uuid/thread';
  static String driverConversationMessages(String uuid) => '/driver/conversations/$uuid/messages';
  static String driverConversationRead(String uuid) => '/driver/conversations/$uuid/read';
  static String driverBookingStartConversation(String bookingUuid) => '/driver/bookings/$bookingUuid/conversation';
  static String driverMessageDelete(String messageUuid) => '/driver/messages/$messageUuid';
  static String driverMessageEdit(String messageUuid) => '/driver/messages/$messageUuid';

  // Messagerie — partagé (passager garde ses propres routes)
  static String conversationMessages(String uuid) => '/conversations/$uuid/messages';
  static String conversationRead(String uuid) => '/conversations/$uuid/read';

  // Avis — conducteur
  static const String driverReviews = '/driver/reviews';
  static String driverReviewReply(String uuid) => '/driver/reviews/$uuid/reply';
}
