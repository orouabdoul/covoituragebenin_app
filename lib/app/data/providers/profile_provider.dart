import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/profile_model.dart';
import 'package:dio/dio.dart';

class ProfileProvider {
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

  Future<ApiResult<ProfileModel>> fetchProfile() async {
    try {
      final opts = await _authOptions();
      final response = await _dio.get(AppApi.driverProfile, options: opts);
      logger.d('driverProfile [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final body = response.data['body'] as Map<String, dynamic>;
        return ApiResult.success(ProfileModel.fromJson(body));
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverProfile: $e');
      return ApiResult.failure(_mapDioError(e));
    } catch (e) {
      logger.e('driverProfile: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  Future<ApiResult<void>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String city,
    required String neighborhood,
    required String addressDetails,
  }) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.put(
        AppApi.driverProfile,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'city': city,
          'neighborhood': neighborhood,
          'address_details': addressDetails,
        },
        options: opts,
      );
      logger.d('updateProfile [${response.statusCode}]');
      if (response.statusCode == 200) return ApiResult.success(null);
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 422) return ApiResult.failure(AppError.validationError);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('updateProfile: $e');
      return ApiResult.failure(_mapDioError(e));
    } catch (e) {
      logger.e('updateProfile: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  Future<ApiResult<ProfilePreferencesData>> updatePreferences({
    required bool autoAvailability,
    required bool notificationsEnabled,
  }) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.patch(
        AppApi.driverPreferences,
        data: {
          'auto_availability': autoAvailability,
          'notifications_enabled': notificationsEnabled,
        },
        options: opts,
      );
      logger.d('updatePreferences [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final body = response.data['body'] as Map<String, dynamic>;
        return ApiResult.success(ProfilePreferencesData.fromJson(body));
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 422) return ApiResult.failure(AppError.validationError);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('updatePreferences: $e');
      return ApiResult.failure(_mapDioError(e));
    } catch (e) {
      logger.e('updatePreferences: $e');
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
