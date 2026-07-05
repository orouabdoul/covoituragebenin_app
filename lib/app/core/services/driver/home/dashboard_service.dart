import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/dashboard_model.dart';

abstract class DashboardService {
  Future<ApiResult<DashboardModel>> fetchDashboard();
  Future<ApiResult<({bool isOnline, String mode})>> updateAvailability({
    required bool isOnline,
    required String mode,
  });
}
