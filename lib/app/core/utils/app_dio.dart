import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:dio/dio.dart';

class AppDio {
  static Dio create() {
    final dio = Dio(BaseOptions(
      baseUrl: AppApi.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Accept': 'application/json'},
    ));
    dio.interceptors.add(_AccountStatusInterceptor());
    return dio;
  }

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

/// Intercepteur global : toute réponse 403 avec account_status=suspended
/// met à jour UserController.accountBlocked immédiatement.
class _AccountStatusInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 403) {
      final data = response.data;
      if (data is Map) {
        final body = data['body'];
        if (body is Map && body['account_status'] == 'suspended') {
          _markBlocked();
        }
      }
    }
    handler.next(response);
  }

  void _markBlocked() {
    try {
      final uc = UserController.instance;
      if (!uc.accountBlocked.value) {
        uc.accountBlocked.value = true;
        // Persiste pour les prochains démarrages
        uc.persistBlockedStatus(blocked: true);
      }
    } catch (_) {}
  }
}
