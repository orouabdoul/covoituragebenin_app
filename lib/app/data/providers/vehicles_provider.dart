import 'package:dio/dio.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';

class VehiclesProvider {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppApi.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ));

  /// Set by [createVehicle] when the API returns 422 so the controller can
  /// show the backend's message rather than the generic validationError text.
  String? lastValidationMessage;

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<ApiResult<Map<String, dynamic>>> createVehicle(
      Map<String, dynamic> data) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.driverVehicles,
        data: data,
        options: opts,
      );
      logger.d('createVehicle [${res.statusCode}]');

      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
            res.data['body']['vehicle'] as Map<String, dynamic>);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 422) {
        lastValidationMessage = _extractMessage(res.data);
        return ApiResult.failure(AppError.validationError);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('createVehicle: $e');
      return ApiResult.failure(_mapDio(e));
    }
  }

  String _extractMessage(dynamic data) {
    try {
      final errors = data['errors'] as Map?;
      if (errors != null && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first as String;
      }
      return data['message'] as String? ?? 'Données invalides.';
    } catch (_) {
      return 'Données invalides.';
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
