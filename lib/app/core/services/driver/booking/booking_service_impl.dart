import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'booking_service.dart';

class BookingServiceImpl implements BookingService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<List<Map<String, dynamic>>>> fetchDriverBookings() async {
    try {
      final opts = await _authOptions();
      final response = await _dio.get(AppApi.driverBookings, options: opts);
      logger.d('driverBookings [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final raw = response.data['body'];
        final rawList = raw is List ? raw : (raw is Map ? (raw['data'] ?? raw['bookings'] ?? raw['items'] ?? []) : []);
        final list = (rawList as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        return ApiResult.success(list);
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverBookings: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverBookings: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> acceptBooking(String uuid) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.post(AppApi.bookingAccept(uuid), data: {}, options: opts);
      logger.d('acceptBooking [$uuid] [${response.statusCode}] body=${response.data}');
      if (response.statusCode == 200 && response.data['success'] == true) return ApiResult.success(null);
      if (response.statusCode == 200) return ApiResult.success(null);
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 422) return ApiResult.failure(AppError.validationError);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('acceptBooking: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('acceptBooking: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> rejectBooking(String uuid) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.post(AppApi.bookingReject(uuid), data: {}, options: opts);
      logger.d('rejectBooking [$uuid] [${response.statusCode}] body=${response.data}');
      if (response.statusCode == 200 && response.data['success'] == true) return ApiResult.success(null);
      if (response.statusCode == 200) return ApiResult.success(null);
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 422) return ApiResult.failure(AppError.validationError);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('rejectBooking: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('rejectBooking: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

}
