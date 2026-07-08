import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/notification_model.dart';
import 'package:dio/dio.dart';
import 'passenger_notifications_service.dart';

class PassengerNotificationsServiceImpl
    implements PassengerNotificationsService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<PassengerNotificationsBodyModel>> fetchNotifications({
    String filter = 'all',
    int perPage = 30,
  }) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.get(
        AppApi.passengerNotifications,
        queryParameters: {'filter': filter, 'per_page': perPage},
        options: opts,
      );
      logger.d(
          'passengerNotifications [${response.statusCode}] ${response.data}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final body = response.data['body'] as Map<String, dynamic>;
        return ApiResult.success(
            PassengerNotificationsBodyModel.fromJson(body));
      }
      if (response.statusCode == 401) {
        return ApiResult.failure(AppError.unAuthenticated);
      }
      if (response.statusCode == 403) {
        return ApiResult.failure(AppError.permissionDenied);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('passengerNotifications: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerNotifications: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> markAsRead(String id) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.post(
        AppApi.passengerNotificationRead(id),
        options: opts,
      );
      if (response.statusCode == 200) return ApiResult.success(null);
      return ApiResult.failure(AppError.unexpected);
    } catch (_) {
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> markAllRead() async {
    try {
      final opts = await _authOptions();
      final response = await _dio.post(
        AppApi.passengerNotificationsReadAll,
        options: opts,
      );
      if (response.statusCode == 200) return ApiResult.success(null);
      return ApiResult.failure(AppError.unexpected);
    } catch (_) {
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> deleteNotification(String id) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.delete(
        AppApi.passengerNotificationDelete(id),
        options: opts,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResult.success(null);
      }
      return ApiResult.failure(AppError.unexpected);
    } catch (_) {
      return ApiResult.failure(AppError.unexpected);
    }
  }
}
