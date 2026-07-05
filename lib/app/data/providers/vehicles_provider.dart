import 'package:dio/dio.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/vehicle_model.dart';

class VehiclesProvider {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppApi.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ));

  String? lastValidationMessage;

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<ApiResult<List<VehicleData>>> listVehicles() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.driverVehicles, options: opts);
      logger.d('listVehicles [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final body = res.data['body'] as Map<String, dynamic>;
        final list = (body['vehicles'] as List?) ?? [];
        return ApiResult.success(
          list
              .map((v) => VehicleData.fromJson(v as Map<String, dynamic>))
              .toList(),
        );
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('listVehicles: $e');
      return ApiResult.failure(_mapDio(e));
    }
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

  Future<ApiResult<void>> updateVehicle(
    String uuid,
    Map<String, dynamic> data,
  ) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.put(
        AppApi.driverVehicle(uuid),
        data: data,
        options: opts,
      );
      logger.d('updateVehicle [$uuid] [${res.statusCode}]');
      if (res.statusCode == 200) return ApiResult.success(null);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      if (res.statusCode == 422) {
        lastValidationMessage = _extractMessage(res.data);
        return ApiResult.failure(AppError.validationError);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('updateVehicle: $e');
      return ApiResult.failure(_mapDio(e));
    }
  }

  Future<ApiResult<void>> deleteVehicle(String uuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.delete(
        AppApi.driverVehicle(uuid),
        options: opts,
      );
      logger.d('deleteVehicle [$uuid] [${res.statusCode}]');
      if (res.statusCode == 200) return ApiResult.success(null);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('deleteVehicle: $e');
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
