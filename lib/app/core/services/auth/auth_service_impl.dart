import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/auth_result.dart';
import 'package:dio/dio.dart';
import 'auth_service.dart';

class AuthServiceImpl implements AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppApi.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ));

  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async {
    try {
      final response = await _dio.post(
        AppApi.sendOtp,
        data: {'phone': phone},
        options: Options(
          validateStatus: (_) => true,
          headers: {'X-CSRF-TOKEN': ''},
        ),
      );
      logger.d('sendOtp [${response.statusCode}] ${response.data}');
      if (response.statusCode == 200) {
        final otpCode = response.data?['body']?['otp_code']?.toString();
        return ApiResult.success(otpCode);
      }
      if (response.statusCode == 422) return ApiResult.failure(AppError.validationError);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('sendOtp: $e');
      if (_isNetworkError(e)) return ApiResult.failure(AppError.socket);
      return ApiResult.failure(AppError.unexpected);
    } catch (e) {
      logger.e('sendOtp: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<AuthResult>> verifyOtp({
    required String phone,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post(
        AppApi.verifyOtp,
        data: {'phone': phone, 'otp_code': otpCode},
        options: Options(
          validateStatus: (_) => true,
          headers: {'X-CSRF-TOKEN': ''},
        ),
      );
      logger.d('verifyOtp [${response.statusCode}] ${response.data}');
      if (response.statusCode == 200) {
        final body = response.data['body'] as Map<String, dynamic>;
        return ApiResult.success(AuthResult.fromJson(body));
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.invalidOtp);
      if (response.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      if (response.statusCode == 422) return ApiResult.failure(AppError.validationError);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('verifyOtp: $e');
      if (_isNetworkError(e)) return ApiResult.failure(AppError.socket);
      final status = e.response?.statusCode;
      if (status == 401) return ApiResult.failure(AppError.invalidOtp);
      if (status == 404) return ApiResult.failure(AppError.userNotFound);
      if (status == 422) return ApiResult.failure(AppError.validationError);
      return ApiResult.failure(AppError.unexpected);
    } catch (e) {
      logger.e('verifyOtp: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  bool _isNetworkError(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError;
}
