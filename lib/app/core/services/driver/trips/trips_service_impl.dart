import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/trips_model.dart';
import 'package:dio/dio.dart';
import 'trips_service.dart';

class TripsServiceImpl implements TripsService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<TripsModel>> fetchTrips({
    String status = 'all',
    int page = 1,
  }) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.get(
        AppApi.driverTrips,
        queryParameters: {'status': status, 'page': page},
        options: opts,
      );
      logger.d('driverTrips [$status] [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final body = response.data['body'] as Map<String, dynamic>;
        return ApiResult.success(TripsModel.fromJson(body));
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverTrips: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverTrips: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> fetchTripForm() async {
    try {
      final opts = await _authOptions();
      final response = await _dio.get(AppApi.driverTripForm, options: opts);
      logger.d('fetchTripForm [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResult.success(response.data['body'] as Map<String, dynamic>);
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 403) {
        final msg = response.data['message'] as String?;
        return ApiResult.failure(AppError.permissionDenied, message: msg);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('fetchTripForm: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('fetchTripForm: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<TripPassengersModel>> fetchTripPassengers(String uuid) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.get(
        AppApi.driverTripPassengers(uuid),
        options: opts,
      );
      logger.d('driverTripPassengers [$uuid] [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final body = response.data['body'] as Map<String, dynamic>;
        return ApiResult.success(TripPassengersModel.fromJson(body));
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (response.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverTripPassengers: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverTripPassengers: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> cancelTrip(String uuid) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.post(
        AppApi.driverTripCancel(uuid),
        options: opts,
      );
      logger.d('driverTripCancel [$uuid] [${response.statusCode}]');
      if (response.statusCode == 200) return ApiResult.success(null);
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (response.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverTripCancel: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverTripCancel: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> publishTrip(Map<String, dynamic> data) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.post(
        AppApi.driverTripPublish,
        data: data,
        options: opts,
      );
      logger.d('publishTrip [${response.statusCode}] ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(null);
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 403) {
        final msg = response.data['message'] as String?;
        return ApiResult.failure(AppError.permissionDenied, message: msg);
      }
      if (response.statusCode == 422) {
        final msg = response.data['message'] as String?;
        return ApiResult.failure(AppError.tripDataInvalid, message: msg);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('publishTrip: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('publishTrip: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> fetchTripRaw(String uuid) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.get(AppApi.driverTripDetail(uuid), options: opts);
      logger.d('fetchTripRaw [$uuid] [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResult.success(response.data['body'] as Map<String, dynamic>);
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('fetchTripRaw: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('fetchTripRaw: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> updateTrip(String uuid, Map<String, dynamic> data) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.put(AppApi.driverTripUpdate(uuid), data: data, options: opts);
      logger.d('updateTrip [$uuid] [${response.statusCode}]');
      if (response.statusCode == 200) return ApiResult.success(null);
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 403) {
        final msg = response.data['message'] as String?;
        return ApiResult.failure(AppError.permissionDenied, message: msg);
      }
      if (response.statusCode == 422) {
        final msg = response.data['message'] as String?;
        return ApiResult.failure(AppError.validationError, message: msg);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('updateTrip: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('updateTrip: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

}
