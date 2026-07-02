import 'package:dio/dio.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';

class SupportProvider {
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

  Future<ApiResult<List<Map<String, dynamic>>>> fetchFaq() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.driverSupportFaq, options: opts);
      logger.d('driverSupportFaq [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = (res.data['body'] as List? ?? []).cast<Map<String, dynamic>>();
        return ApiResult.success(list);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverSupportFaq: $e');
      return ApiResult.failure(_mapDio(e));
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> fetchTickets() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.driverSupportTickets, options: opts);
      logger.d('driverSupportTickets [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = (res.data['body'] as List? ?? []).cast<Map<String, dynamic>>();
        return ApiResult.success(list);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverSupportTickets: $e');
      return ApiResult.failure(_mapDio(e));
    }
  }

  Future<ApiResult<void>> createTicket({
    required String subject,
    required String description,
  }) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.driverSupportTickets,
        data: {'subject': subject, 'description': description},
        options: opts,
      );
      logger.d('createTicket [${res.statusCode}]');
      if (res.statusCode == 201 && res.data['success'] == true) {
        return ApiResult.success(null);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('createTicket: $e');
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
