import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/auth/auth_result.dart';
import 'package:covoiturage_benin_app/app/data/models/auth/user_model.dart';
import 'package:dio/dio.dart';
import 'auth_service.dart';

class AuthServiceImpl implements AuthService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions({Duration? receiveTimeout}) async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
      receiveTimeout: receiveTimeout,
    );
  }

  @override
  Future<ApiResult<OtpSendResult>> sendOtp({required String phone}) async {
    try {
      final response = await _dio.post(
        AppApi.sendOtp,
        data: {'phone': phone},
        options: Options(
          validateStatus: (_) => true,
          headers: {'X-CSRF-TOKEN': ''},
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
      logger.d('sendOtp [${response.statusCode}] ${response.data}');

      if (response.statusCode == 200) {
        final body = response.data?['body'];
        final otpCode = body?['otp_code']?.toString();
        final resendIn = body?['resend_available_in'] as int?;
        return ApiResult.success(OtpSendResult(otpCode: otpCode, resendIn: resendIn));
      }

      if (response.statusCode == 429) {
        final resendIn = response.data?['body']?['resend_available_in'] as int?;
        // OTP already active — navigate to OTP screen with remaining cooldown.
        return ApiResult.success(OtpSendResult(resendIn: resendIn ?? 60, alreadyActive: true));
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

  @override
  Future<ApiResult<void>> logout() async {
    try {
      final opts = await _authOptions();
      final response = await _dio.post(AppApi.logout, options: opts);
      logger.d('logout [${response.statusCode}]');
      // Révoque côté serveur ; on efface la session locale dans tous les cas.
      await UserController.instance.logout();
      if (response.statusCode == 200) return ApiResult.success(null);
      if (response.statusCode == 401) return ApiResult.success(null); // déjà expiré
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('logout: $e');
      // On efface quand même la session locale même si le réseau échoue.
      await UserController.instance.logout();
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('logout: $e');
      await UserController.instance.logout();
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> setUserRole(String role) async {
    try {
      final opts = await _authOptions();
      final response = await _dio.post(
        AppApi.roles,
        data: {'role': role},
        options: opts,
      );
      logger.d('setUserRole [${response.statusCode}] ${response.data}');
      if (response.statusCode == 200) return ApiResult.success(null);
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('setUserRole: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('setUserRole: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<AuthResult>> me() async {
    try {
      final opts = await _authOptions(receiveTimeout: const Duration(seconds: 15));
      final response = await _dio.get(AppApi.me, options: opts);
      logger.d('me [${response.statusCode}] ${response.data}');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final body = response.data['body'] as Map<String, dynamic>;
        // /me retourne les champs user directement dans body (pas de clé 'user')
        final user = UserModel.fromJson(body);
        final currentToken = await UserController.instance.getSessionToken();
        final profileComplete = body['profile'] != null;
        return ApiResult.success(AuthResult(
          token: currentToken,
          profileComplete: profileComplete,
          isVerified: body['is_verified'] as bool? ?? false,
          user: user,
        ));
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (response.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('me: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('me: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }
}
