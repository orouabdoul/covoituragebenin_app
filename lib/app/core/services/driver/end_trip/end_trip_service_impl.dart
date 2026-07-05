import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/end_trip_summary_model.dart';
import 'package:dio/dio.dart';
import 'end_trip_service.dart';

class EndTripServiceImpl implements EndTripService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<EndTripSummaryModel>> fetchEndSummary(String uuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.driverTripEndSummary(uuid), options: opts);
      logger.d('endSummary[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
          EndTripSummaryModel.fromJson(res.data['body'] as Map<String, dynamic>),
        );
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('endSummary: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('endSummary: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> endTrip(String uuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(AppApi.tripEnd(uuid), options: opts);
      logger.d('endTrip[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(null);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('endTrip: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('endTrip: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

}
