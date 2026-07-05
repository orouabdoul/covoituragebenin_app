import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/trip_detail_model.dart';

abstract class TripDetailService {
  Future<ApiResult<TripDetailModel>> fetchTripDetail(String uuid);
  Future<ApiResult<void>> updateTrip(
    String uuid, {
    required Map<String, dynamic> fields,
  });
}
