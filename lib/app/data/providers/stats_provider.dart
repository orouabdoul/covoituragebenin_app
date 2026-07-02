import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:dio/dio.dart';

class StatsProvider {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppApi.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ));

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<ApiResult<Map<String, dynamic>>> fetchStats(String period) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(
        AppApi.driverStats,
        queryParameters: {'period': period},
        options: opts,
      );
      logger.d('driverStats[$period] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(res.data['body'] as Map<String, dynamic>);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverStats: $e');
      return ApiResult.failure(_mapDio(e));
    }
  }

  AppError _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return AppError.socket;
    }
    return AppError.unexpected;
  }
}
