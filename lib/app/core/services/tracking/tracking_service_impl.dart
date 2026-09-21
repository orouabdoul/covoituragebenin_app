import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/tracking/trip_tracking_model.dart';
import 'package:dio/dio.dart';
import 'tracking_service.dart';

class TrackingServiceImpl implements TrackingService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOpts() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // ── Polling passager ────────────────────────────────────────────────────

  @override
  Future<ApiResult<TripTrackingModel>> fetchTripTracking(String tripUuid) async {
    try {
      final res = await _dio.get(
        AppApi.tripTracking(tripUuid),
        options: await _authOpts(),
      );
      logger.d('tripTracking[$tripUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 404) return ApiResult.failure(AppError.tripNotFound);
      if (res.statusCode == 200 &&
          res.data is Map &&
          res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          return ApiResult.success(TripTrackingModel.fromJson(body));
        }
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('tripTracking: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('tripTracking: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Push GPS conducteur ──────────────────────────────────────────────────

  @override
  Future<ApiResult<void>> pushLocation(
    String tripUuid, {
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
  }) async {
    try {
      final res = await _dio.post(
        AppApi.tripLocation(tripUuid),
        data: {
          'latitude':  latitude,
          'longitude': longitude,
          if (speed   != null) 'speed':   speed,
          if (heading != null) 'heading': heading,
        },
        options: await _authOpts(),
      );
      logger.d('pushLocation[$tripUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 || res.statusCode == 201) return ApiResult.success(null);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('pushLocation: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('pushLocation: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Démarrer trajet ──────────────────────────────────────────────────────

  @override
  Future<ApiResult<void>> startTrip(String tripUuid) async {
    try {
      final res = await _dio.patch(
        AppApi.tripStart(tripUuid),
        options: await _authOpts(),
      );
      logger.d('startTrip[$tripUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 || res.statusCode == 201) return ApiResult.success(null);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('startTrip: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('startTrip: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Terminer trajet ──────────────────────────────────────────────────────

  @override
  Future<ApiResult<void>> completeTrip(String tripUuid) async {
    try {
      final res = await _dio.patch(
        AppApi.tripComplete(tripUuid),
        options: await _authOpts(),
      );
      logger.d('completeTrip[$tripUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 || res.statusCode == 201) return ApiResult.success(null);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('completeTrip: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('completeTrip: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Réservation active passager ──────────────────────────────────────────

  @override
  Future<ApiResult<ActiveBookingModel?>> fetchPassengerActiveBooking() async {
    try {
      final res = await _dio.get(
        AppApi.passengerActiveBookings,
        queryParameters: {'status': 'active,pending', 'per_page': 5},
        options: await _authOpts(),
      );
      logger.d('passengerActiveBookings [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data is Map) {
        final body = res.data['body'];
        final data = (body is Map ? body['data'] : null) as List?;
        if (data == null || data.isEmpty) return ApiResult.success(null);
        return ApiResult.success(
            ActiveBookingModel.fromJson(data.first as Map<String, dynamic>));
      }
      return ApiResult.success(null);
    } on DioException catch (e) {
      logger.w('passengerActiveBookings: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('passengerActiveBookings: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Trajet actif conducteur ──────────────────────────────────────────────

  @override
  Future<ApiResult<ActiveDriverTripModel?>> fetchDriverActiveTrip() async {
    try {
      final res = await _dio.get(
        AppApi.driverTrips,
        queryParameters: {'status': 'active,pending', 'per_page': 5},
        options: await _authOpts(),
      );
      logger.d('driverActiveTrips [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data is Map) {
        final body = res.data['body'];
        final data = (body is Map ? body['data'] : null) as List?;
        if (data == null || data.isEmpty) return ApiResult.success(null);
        return ApiResult.success(
            ActiveDriverTripModel.fromJson(data.first as Map<String, dynamic>));
      }
      return ApiResult.success(null);
    } on DioException catch (e) {
      logger.w('driverActiveTrips: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('driverActiveTrips: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }
}
