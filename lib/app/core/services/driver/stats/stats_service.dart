import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';

abstract class StatsService {
  Future<ApiResult<Map<String, dynamic>>> fetchStats(String period);
}
