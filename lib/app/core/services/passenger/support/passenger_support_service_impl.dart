import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/support_model.dart';
import 'package:dio/dio.dart';
import 'passenger_support_service.dart';

class PassengerSupportServiceImpl implements PassengerSupportService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<List<FaqItem>>> fetchFaq() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.passengerSupportFaq, options: opts);
      logger.d('passengerSupportFaq [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        final topics = body is Map<String, dynamic>
            ? (body['topics'] as List? ?? [])
            : <dynamic>[];
        final faqs = <FaqItem>[];
        for (final t in topics) {
          if (t is! Map) continue;
          final label = (t['label'] ?? t['key'] ?? '').toString();
          for (final item in (t['items'] as List? ?? [])) {
            if (item is! Map) continue;
            faqs.add(FaqItem(
              question: (item['question'] ?? '').toString(),
              answer: (item['answer'] ?? '').toString(),
              category: label,
            ));
          }
        }
        return ApiResult.success(faqs);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('passengerSupportFaq: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerSupportFaq: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<List<SupportTicket>>> fetchTickets() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.passengerSupportTickets, options: opts);
      logger.d('passengerSupportTickets [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        final List raw = body is List
            ? body
            : body is Map<String, dynamic>
                ? ((body['tickets'] ?? body['data'] ?? []) as List? ?? [])
                : [];
        return ApiResult.success(
            raw.whereType<Map<String, dynamic>>()
                .map((j) => SupportTicket.fromJson(j))
                .toList());
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('passengerSupportTickets: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerSupportTickets: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  String? _lastValidationMessage;
  String? get lastValidationMessage => _lastValidationMessage;

  @override
  Future<ApiResult<SupportTicket>> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      final opts = await _authOptions();

      // Normalise les valeurs pour correspondre au contrat de l'API
      final body = <String, dynamic>{
        'subject':     subject,
        'description': description,
        'priority':    _normalizePriority(priority),
      };
      // Ajoute category seulement si non vide, normalisée en snake_case anglais
      final cat = _normalizeCategory(category);
      if (cat.isNotEmpty) body['category'] = cat;

      final res = await _dio.post(
        AppApi.passengerSupportTickets,
        data: body,
        options: opts,
      );
      logger.d('createSupportTicket [${res.statusCode}] body=${res.data}');

      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 422) {
        _lastValidationMessage = _extractMessage(res.data);
        logger.e('createSupportTicket 422: $_lastValidationMessage');
        return ApiResult.failure(AppError.validationError);
      }
      // Accepte 200 ET 201 (Created)
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data is Map &&
          res.data['success'] == true) {
        final resBody = res.data['body'];
        final ticketJson = (resBody is Map<String, dynamic>)
            ? (resBody['ticket'] is Map<String, dynamic>
                ? resBody['ticket'] as Map<String, dynamic>
                : resBody)
            : <String, dynamic>{};
        return ApiResult.success(SupportTicket.fromJson(ticketJson));
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('createSupportTicket: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('createSupportTicket: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  // Normalise la priorité vers les valeurs acceptées par l'API
  static String _normalizePriority(String p) {
    switch (p.toLowerCase()) {
      case 'low':    return 'low';
      case 'high':   return 'high';
      case 'urgent': return 'urgent';
      default:       return 'medium'; // 'normal' → 'medium'
    }
  }

  // Normalise la catégorie : français accentué → clé anglaise snake_case
  static String _normalizeCategory(String label) {
    final key = label
        .toLowerCase()
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[ùûü]'), 'u')
        .trim();
    if (key.contains('reserv') || key.contains('trajet') || key.contains('booking')) {
      return 'reservation';
    }
    if (key.contains('paie') || key.contains('payment') || key.contains('argent')) {
      return 'payment';
    }
    if (key.contains('secu') || key.contains('security') || key.contains('incident')) {
      return 'security';
    }
    if (key.contains('compte') || key.contains('account') || key.contains('profil')) {
      return 'account';
    }
    if (key.contains('autre') || key.contains('other')) return 'other';
    return key; // valeur brute si non reconnue
  }

  // Extrait le premier message d'erreur de la réponse 422
  static String _extractMessage(dynamic data) {
    try {
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
          if (first is String) return first;
        }
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    } catch (_) {}
    return 'Données invalides.';
  }
}
