import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/home_model.dart';

abstract class PassengerHomeService {
  Future<ApiResult<PassengerHomeDashboard>> fetchDashboard();
}
