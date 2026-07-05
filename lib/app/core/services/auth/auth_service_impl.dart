import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/auth/auth_result.dart';
import 'package:dio/dio.dart';
import 'auth_service.dart';

class AuthServiceImpl implements AuthService {
  final Dio _dio = AppDio.create();

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
      return ApiResult.failure(AppDio.classifyDioError(e));
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
      final classifiedError = AppDio.classifyDioError(e);
      if (classifiedError != AppError.unexpected) return ApiResult.failure(classifiedError);
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

}
