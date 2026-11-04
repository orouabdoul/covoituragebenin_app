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
      final res = await _dio.post(
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
  Future<ApiResult<Map<String, dynamic>>> completeTrip(String tripUuid) async {
    try {
      final res = await _dio.post(
        AppApi.tripEnd(tripUuid),
        options: await _authOpts(),
      );
      logger.d('completeTrip[$tripUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = (res.data is Map ? res.data['body'] : null) as Map<String, dynamic>? ?? {};
        return ApiResult.success(body);
      }
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

  // ── Demande d'embarquement ───────────────────────────────────────────────

  @override
  Future<ApiResult<String>> requestBoarding(
    String tripUuid,
    String bookingUuid, {
    double? driverLat,
    double? driverLng,
  }) async {
    try {
      final res = await _dio.post(
        AppApi.driverTripBoardingRequest(tripUuid, bookingUuid),
        data: {
          if (driverLat != null) 'driver_lat': driverLat,
          if (driverLng != null) 'driver_lng': driverLng,
        },
        options: await _authOpts(),
      );
      logger.d('requestBoarding[$tripUuid/$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final boardingCode = res.data['body']?['boarding_code'] as String? ?? '';
        return ApiResult.success(boardingCode);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('requestBoarding: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('requestBoarding: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Vérification code embarquement ──────────────────────────────────────

  @override
  Future<ApiResult<void>> verifyBoardingCode(
    String tripUuid,
    String bookingUuid,
    String code, {
    double? driverLat,
    double? driverLng,
  }) async {
    try {
      final res = await _dio.post(
        AppApi.driverTripVerifyCode(tripUuid, bookingUuid),
        data: {
          'code': code,
          if (driverLat != null) 'driver_lat': driverLat,
          if (driverLng != null) 'driver_lng': driverLng,
        },
        options: await _authOpts(),
      );
      logger.d('verifyBoardingCode[$tripUuid/$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 422) return ApiResult.failure(AppError.unexpected);
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(null);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('verifyBoardingCode: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('verifyBoardingCode: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Confirmation embarquement (passager) ────────────────────────────────

  @override
  Future<ApiResult<void>> confirmPickupBoarding(
    String bookingUuid, {
    double? passengerLat,
    double? passengerLng,
  }) async {
    try {
      final res = await _dio.post(
        AppApi.confirmPickup(bookingUuid),
        data: {
          if (passengerLat != null) 'passenger_lat': passengerLat,
          if (passengerLng != null) 'passenger_lng': passengerLng,
        },
        options: await _authOpts(),
      );
      logger.d('confirmPickupBoarding[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200) return ApiResult.success(null);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('confirmPickupBoarding: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('confirmPickupBoarding: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Dépôt passager (conducteur) ─────────────────────────────────────────

  @override
  Future<ApiResult<void>> dropoffPassenger(
    String tripUuid,
    String bookingUuid,
  ) async {
    try {
      final res = await _dio.post(
        AppApi.driverTripDropoff(tripUuid, bookingUuid),
        options: await _authOpts(),
      );
      logger.d('dropoffPassenger[$tripUuid/$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data['success'] == true) return ApiResult.success(null);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('dropoffPassenger: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('dropoffPassenger: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── No-show passager (conducteur) ───────────────────────────────────────

  @override
  Future<ApiResult<void>> reportPassengerNoShow(
    String tripUuid,
    String bookingUuid,
  ) async {
    try {
      final res = await _dio.post(
        AppApi.driverTripNoShow(tripUuid, bookingUuid),
        options: await _authOpts(),
      );
      logger.d('reportPassengerNoShow[$tripUuid/$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data['success'] == true) return ApiResult.success(null);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('reportPassengerNoShow: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('reportPassengerNoShow: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Conducteur absent (passager) ─────────────────────────────────────────

  @override
  Future<ApiResult<Map<String, dynamic>>> reportDriverAbsent(String bookingUuid) async {
    try {
      final res = await _dio.post(
        AppApi.passengerReportDriverAbsent(bookingUuid),
        options: await _authOpts(),
      );
      logger.d('reportDriverAbsent[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final body = (res.data['body'] as Map<String, dynamic>?) ?? {};
        return ApiResult.success(body);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('reportDriverAbsent: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('reportDriverAbsent: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Confirmation manuelle embarquement (téléphone mort) ─────────────────

  @override
  Future<ApiResult<void>> confirmBoardingManual(
    String tripUuid,
    String bookingUuid,
  ) async {
    try {
      final res = await _dio.post(
        AppApi.driverTripBoardingManual(tripUuid, bookingUuid),
        options: await _authOpts(),
      );
      logger.d('confirmBoardingManual[$tripUuid/$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data['success'] == true) return ApiResult.success(null);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('confirmBoardingManual: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('confirmBoardingManual: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Refus d'embarquement (passager) ─────────────────────────────────────

  @override
  Future<ApiResult<void>> refuseBoarding(
    String bookingUuid, {
    double? passengerLat,
    double? passengerLng,
  }) async {
    try {
      final res = await _dio.post(
        AppApi.passengerBoardingRefuse(bookingUuid),
        data: {
          if (passengerLat != null) 'passenger_lat': passengerLat,
          if (passengerLng != null) 'passenger_lng': passengerLng,
        },
        options: await _authOpts(),
      );
      logger.d('refuseBoarding[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200) return ApiResult.success(null);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('refuseBoarding: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('refuseBoarding: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // ── Carte conducteur ─────────────────────────────────────────────────────

  @override
  Future<ApiResult<DriverMapData>> fetchDriverMapData(String tripUuid) async {
    try {
      final res = await _dio.get(
        AppApi.driverTripMap(tripUuid),
        options: await _authOpts(),
      );
      logger.d('driverMapData[$tripUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 &&
          res.data is Map &&
          res.data['success'] == true) {
        final body = res.data['body'] as Map<String, dynamic>?;
        if (body != null) {
          return ApiResult.success(DriverMapData.fromJson(body));
        }
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.w('driverMapData: ${e.type}');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.w('driverMapData: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }
}
