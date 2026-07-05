import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:dio/dio.dart';

class BookingProvider {
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

  Future<ApiResult<List<Map<String, dynamic>>>> fetchDriverBookings() async {
    try {
      final opts = await _authOptions();
      final response = await _dio.get(AppApi.driverBookings, options: opts);
      logger.d('driverBookings [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list =
            (response.data['body'] as List).cast<Map<String, dynamic>>();
        return ApiResult.success(list);
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverBookings: $e');
      return ApiResult.failure(_mapDioError(e));
    } catch (e) {
      logger.e('driverBookings: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  Future<ApiResult<void>> acceptBooking(String uuid) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.post(AppApi.bookingAccept(uuid), options: opts);
      logger.d('acceptBooking [$uuid] [${response.statusCode}]');
      if (response.statusCode == 200) return ApiResult.success(null);
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 422) return ApiResult.failure(AppError.validationError);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('acceptBooking: $e');
      return ApiResult.failure(_mapDioError(e));
    } catch (e) {
      logger.e('acceptBooking: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  Future<ApiResult<void>> rejectBooking(String uuid) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.post(AppApi.bookingReject(uuid), options: opts);
      logger.d('rejectBooking [$uuid] [${response.statusCode}]');
      if (response.statusCode == 200) return ApiResult.success(null);
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 422) return ApiResult.failure(AppError.validationError);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('rejectBooking: $e');
      return ApiResult.failure(_mapDioError(e));
    } catch (e) {
      logger.e('rejectBooking: $e');
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
