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
      receiveTimeout: const Duration(seconds: 35),
      headers: {'Accept': 'application/json'},
    ));
    dio.transformer = BackgroundTransformer();
    dio.interceptors.add(_AccountStatusInterceptor());
    dio.interceptors.add(_UnauthorizedInterceptor());
    dio.interceptors.add(_RetryOnTimeoutInterceptor(dio));
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
        // HandshakeException (SSL/TLS), OSError, SocketException, et tout
        // autre échec réseau bas niveau remontent en DioExceptionType.unknown
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

/// Intercepteur global : toute réponse 401 depuis une route authentifiée
/// déconnecte l'utilisateur et le renvoie à l'écran de connexion.
class _UnauthorizedInterceptor extends Interceptor {
  static bool _redirecting = false;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 401 && !_redirecting) {
      // Le endpoint /auth/register retourne 401 quand le register_token est
      // expiré — c'est géré par le contrôleur, pas par cet intercepteur.
      final path = response.requestOptions.path;
      if (path != AppApi.register) {
        _handleUnauthorized();
      }
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

/// Retry automatique sur receiveTimeout (Render.com cold start ~50-60s).
/// Une seule tentative, uniquement pour les requêtes GET.
/// Utilise l'en-tête interne _retried pour éviter les boucles infinies.
class _RetryOnTimeoutInterceptor extends Interceptor {
  static const String _retriedKey = '_retried';
  final Dio dio;

  _RetryOnTimeoutInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final opts = err.requestOptions;
    final alreadyRetried = opts.extra[_retriedKey] == true;
    final isGet = opts.method.toUpperCase() == 'GET';

    if (err.type == DioExceptionType.receiveTimeout && isGet && !alreadyRetried) {
      // Attendre 1s — le serveur Render est maintenant chaud après le premier timeout
      await Future.delayed(const Duration(seconds: 1));
      try {
        final retryOpts = opts.copyWith(
          extra: {...opts.extra, _retriedKey: true},
          receiveTimeout: const Duration(seconds: 15), // serveur chaud → réponse rapide
        );
        final response = await dio.fetch(retryOpts);
        handler.resolve(response);
        return;
      } catch (e) {
        // Le retry a aussi échoué — laisser passer l'erreur originale
      }
    }
    handler.next(err);
  }
}
