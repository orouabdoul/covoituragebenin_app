import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/dashboard_model.dart';
import 'package:dio/dio.dart';

class DashboardProvider {
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

  Future<ApiResult<DashboardModel>> fetchDashboard() async {
    try {
      final opts = await _authOptions();
      final response = await _dio.get(AppApi.driverDashboard, options: opts);
      logger.d('driverDashboard [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final body = response.data['body'] as Map<String, dynamic>;
        return ApiResult.success(DashboardModel.fromJson(body));
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverDashboard: $e');
      return ApiResult.failure(_mapDioError(e));
    } catch (e) {
      logger.e('driverDashboard: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  Future<ApiResult<({bool isOnline, String mode})>> updateAvailability({
    required bool isOnline,
    required String mode,
  }) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.patch(
        AppApi.driverAvailability,
        data: {'is_online': isOnline, 'mode': mode},
        options: opts,
      );
      logger.d('driverAvailability [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final body = response.data['body'] as Map<String, dynamic>;
        return ApiResult.success((
          isOnline: (body['is_online'] as bool?) ?? isOnline,
          mode: (body['availability_mode'] as String?) ?? mode,
        ));
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (response.statusCode == 422) return ApiResult.failure(AppError.validationError);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverAvailability: $e');
      return ApiResult.failure(_mapDioError(e));
    } catch (e) {
      logger.e('driverAvailability: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  AppError _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return AppError.socket;
    }
    return AppError.unexpected;
  }
}
