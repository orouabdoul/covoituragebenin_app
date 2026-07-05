import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/pre_departure_model.dart';

abstract class ActiveTripService {
  Future<ApiResult<PreDepartureModel>> fetchPreDeparture(String uuid);
  Future<ApiResult<void>> startTrip(String uuid);
}
