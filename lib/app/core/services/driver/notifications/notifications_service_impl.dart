import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/notification_driver_model.dart';
import 'package:dio/dio.dart';
import 'notifications_service.dart';

class NotificationsServiceImpl implements NotificationsService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<NotificationsBodyModel>> fetchNotifications({
    String filter = 'all',
    int perPage = 30,
  }) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(
        AppApi.driverNotifications,
        queryParameters: {'filter': filter, 'per_page': perPage},
        options: opts,
      );
      logger.d('fetchNotifications[$filter] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
          NotificationsBodyModel.fromJson(res.data['body'] as Map<String, dynamic>),
        );
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('fetchNotifications: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('fetchNotifications: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> markAsRead(String id) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(AppApi.driverNotificationRead(id), options: opts);
      logger.d('markAsRead[$id] [${res.statusCode}]');
      if (res.statusCode == 200) return ApiResult.success(null);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('markAsRead: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('markAsRead: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> markAllRead() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(AppApi.driverNotificationsReadAll, options: opts);
      logger.d('markAllRead [${res.statusCode}]');
      if (res.statusCode == 200) return ApiResult.success(null);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('markAllRead: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('markAllRead: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

}
