import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/tracking/trip_tracking_model.dart';

abstract class TrackingService {
  // Polling passager — GET /trips/{uuid}/tracking
  Future<ApiResult<TripTrackingModel>> fetchTripTracking(String tripUuid);

  // Push GPS conducteur — POST /trips/{uuid}/location
  Future<ApiResult<void>> pushLocation(
    String tripUuid, {
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
  });

  // Démarrer un trajet — PATCH /trips/{uuid}/start
  Future<ApiResult<void>> startTrip(String tripUuid);

  // Terminer un trajet — POST /trips/{uuid}/end
  // Retourne pending_amount + release_at (fenêtre 2h)
  Future<ApiResult<Map<String, dynamic>>> completeTrip(String tripUuid);

  // Réservation active du passager — GET /passenger/bookings?status=active,pending
  Future<ApiResult<ActiveBookingModel?>> fetchPassengerActiveBooking();

  // Trajet actif du conducteur — GET /driver/trips?status=active,pending
  Future<ApiResult<ActiveDriverTripModel?>> fetchDriverActiveTrip();

  // Embarquement — POST /driver/trips/{uuid}/stops/{bookingUuid}/boarding-request
  Future<ApiResult<String>> requestBoarding(
    String tripUuid,
    String bookingUuid, {
    double? driverLat,
    double? driverLng,
  });

  // Vérification code — POST /driver/trips/{uuid}/stops/{bookingUuid}/verify-code
  Future<ApiResult<void>> verifyBoardingCode(
    String tripUuid,
    String bookingUuid,
    String code, {
    double? driverLat,
    double? driverLng,
  });

  // Confirmation embarquement passager — POST /passenger/bookings/{uuid}/pickup-confirm
  Future<ApiResult<void>> confirmPickupBoarding(
    String bookingUuid, {
    double? passengerLat,
    double? passengerLng,
  });

  // Refus embarquement passager — POST /passenger/bookings/{uuid}/boarding-refuse
  Future<ApiResult<void>> refuseBoarding(
    String bookingUuid, {
    double? passengerLat,
    double? passengerLng,
  });

  // Dépôt passager — POST /driver/trips/{uuid}/stops/{bookingUuid}/dropoff
  Future<ApiResult<void>> dropoffPassenger(
    String tripUuid,
    String bookingUuid,
  );

  // Conducteur signale passager absent — POST /driver/trips/{uuid}/stops/{bookingUuid}/no-show
  Future<ApiResult<void>> reportPassengerNoShow(
    String tripUuid,
    String bookingUuid,
  );

  // Confirmation manuelle embarquement (téléphone mort) — POST /driver/trips/{uuid}/stops/{bookingUuid}/confirm-boarding-manual
  Future<ApiResult<void>> confirmBoardingManual(
    String tripUuid,
    String bookingUuid,
  );

  // Passager signale conducteur absent — POST /passenger/bookings/{uuid}/report-driver-absent
  // Retourne driverEnRoute:bool, autoCancel:bool
  Future<ApiResult<Map<String, dynamic>>> reportDriverAbsent(String bookingUuid);
}
