import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:dio/dio.dart';

class AppDio {
  static Dio create() => Dio(BaseOptions(
        baseUrl: AppApi.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 90),
        headers: {'Accept': 'application/json'},
      ));

  static AppError classifyDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.receiveTimeout:
        return AppError.serverTimeout;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return AppError.socket;
      default:
        return AppError.unexpected;
    }
  }
}
