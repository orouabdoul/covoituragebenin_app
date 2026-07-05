import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/end_trip_summary_model.dart';

abstract class EndTripService {
  Future<ApiResult<EndTripSummaryModel>> fetchEndSummary(String uuid);
  Future<ApiResult<void>> endTrip(String uuid);
}
