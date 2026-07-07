import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/stats_model.dart';
import 'package:dio/dio.dart';
import 'passenger_stats_service.dart';

class PassengerStatsServiceImpl implements PassengerStatsService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<PassengerStatsModel>> fetchStats() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.passengerStats, options: opts);
      logger.d('passengerStats [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
            PassengerStatsModel.fromJson(res.data['body'] as Map<String, dynamic>));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('passengerStats: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerStats: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }
}
