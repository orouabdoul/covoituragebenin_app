import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/trips_model.dart';

abstract class TripsService {
  Future<ApiResult<TripsModel>> fetchTrips({
    String status = 'all',
    int page = 1,
  });
  Future<ApiResult<Map<String, dynamic>>> fetchTripForm();
  Future<ApiResult<TripPassengersModel>> fetchTripPassengers(String uuid);
  Future<ApiResult<void>> cancelTrip(String uuid);
  Future<ApiResult<void>> publishTrip(Map<String, dynamic> data);
  Future<ApiResult<Map<String, dynamic>>> fetchTripRaw(String uuid);
  Future<ApiResult<void>> updateTrip(String uuid, Map<String, dynamic> data);
}
