import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:dio/dio.dart';

class SafetyProvider {
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

  Future<ApiResult<List<Map<String, dynamic>>>> fetchContacts() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.driverSafetyContacts, options: opts);
      logger.d('safetyContacts [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = (res.data['body']['contacts'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        return ApiResult.success(list);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('safetyContacts: $e');
      return ApiResult.failure(_mapDio(e));
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> addContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.driverSafetyContacts,
        data: {'name': name, 'phone': phone, 'relation': relation},
        options: opts,
      );
      logger.d('addContact [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = (res.data['body']['contacts'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        return ApiResult.success(list);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('addContact: $e');
      return ApiResult.failure(_mapDio(e));
    }
  }

  Future<ApiResult<List<Map<String, dynamic>>>> removeContact(String id) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.delete(AppApi.driverSafetyContact(id), options: opts);
      logger.d('removeContact [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = (res.data['body']['contacts'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        return ApiResult.success(list);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('removeContact: $e');
      return ApiResult.failure(_mapDio(e));
    }
  }

  Future<ApiResult<void>> sendSos() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(AppApi.driverSafetySos, options: opts);
      logger.d('sendSos [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(null);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('sendSos: $e');
      return ApiResult.failure(_mapDio(e));
    }
  }

  Future<ApiResult<void>> reportIncident({
    required String category,
    String? description,
  }) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.driverSafetyIncidents,
        data: {'category': category, 'description': description},
        options: opts,
      );
      logger.d('reportIncident [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(null);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('reportIncident: $e');
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
