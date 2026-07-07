import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/trip_history_model.dart';

abstract class PassengerTripsService {
  Future<ApiResult<TripHistoryResult>> fetchHistory();
}
