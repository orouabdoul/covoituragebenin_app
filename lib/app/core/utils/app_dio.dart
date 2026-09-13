import 'dart:io';

import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

class AppDio {
  static Dio create() {
    final dio = Dio(BaseOptions(
      baseUrl: AppApi.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ));
    dio.transformer = BackgroundTransformer();
    dio.interceptors.add(_AccountStatusInterceptor());
    dio.interceptors.add(_UnauthorizedInterceptor());
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
      case DioExceptionType.unknown:
        if (e.error is SocketException || e.error is HttpException) {
          return AppError.socket;
        }
        return AppError.unexpected;
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

/// Intercepteur global : toute réponse 401 depuis une route authentifiée
/// déconnecte l'utilisateur et le renvoie à l'écran de connexion.
class _UnauthorizedInterceptor extends Interceptor {
  static bool _redirecting = false;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 401 && !_redirecting) {
      _handleUnauthorized();
    }
    handler.next(response);
  }

  Future<void> _handleUnauthorized() async {
    _redirecting = true;
    try {
      await UserController.instance.logout();
    } catch (_) {}
    final current = Get.currentRoute;
    if (current != AppRoutes.register && current != AppRoutes.otpCode) {
      Get.offAllNamed(AppRoutes.register);
    }
    await Future.delayed(const Duration(seconds: 3));
    _redirecting = false;
  }
}
