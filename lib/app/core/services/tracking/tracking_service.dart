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

  // Terminer un trajet — PATCH /trips/{uuid}/complete
  Future<ApiResult<void>> completeTrip(String tripUuid);

  // Réservation active du passager — GET /passenger/bookings?status=active,pending
  Future<ApiResult<ActiveBookingModel?>> fetchPassengerActiveBooking();

  // Trajet actif du conducteur — GET /driver/trips?status=active,pending
  Future<ApiResult<ActiveDriverTripModel?>> fetchDriverActiveTrip();
}
