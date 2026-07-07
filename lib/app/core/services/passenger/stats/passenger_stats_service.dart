import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/stats_model.dart';

abstract class PassengerStatsService {
  Future<ApiResult<PassengerStatsModel>> fetchStats();
}
