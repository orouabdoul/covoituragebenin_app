import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'support_service.dart';

class SupportServiceImpl implements SupportService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<List<Map<String, dynamic>>>> fetchFaq() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.driverSupportFaq, options: opts);
      logger.d('driverSupportFaq [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final body = res.data['body'];
        final List<dynamic> rawList;
        if (body is List) {
          rawList = body;
        } else if (body is Map) {
          final nested = body['data'] ?? body['faqs'] ?? body['items'] ?? body['list'];
          rawList = nested is List ? nested : [];
        } else {
          rawList = [];
        }
        return ApiResult.success(rawList.whereType<Map<String, dynamic>>().toList());
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverSupportFaq: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverSupportFaq: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<List<Map<String, dynamic>>>> fetchTickets() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.driverSupportTickets, options: opts);
      logger.d('driverSupportTickets [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final body = res.data['body'];
        final List<dynamic> rawList;
        if (body is List) {
          rawList = body;
        } else if (body is Map) {
          final nested = body['data'] ?? body['tickets'] ?? body['items'] ?? body['list'];
          rawList = nested is List ? nested : [];
        } else {
          rawList = [];
        }
        return ApiResult.success(rawList.whereType<Map<String, dynamic>>().toList());
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverSupportTickets: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverSupportTickets: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  String? _lastValidationMessage;
  String? get lastValidationMessage => _lastValidationMessage;

  @override
  Future<ApiResult<void>> createTicket({
    required String subject,
    required String description,
    String priority = 'medium',
  }) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.driverSupportTickets,
        data: {'subject': subject, 'description': description, 'priority': priority},
        options: opts,
      );
      logger.d('createTicket [${res.statusCode}]');
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data['success'] == true) {
        return ApiResult.success(null);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 422) {
        _lastValidationMessage = _extractMessage(res.data);
        return ApiResult.failure(AppError.validationError);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('createTicket: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('createTicket: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  String _extractMessage(dynamic data) {
    try {
      final errors = data['errors'] as Map?;
      if (errors != null && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first as String;
      }
      return data['message'] as String? ?? 'Données invalides.';
    } catch (_) {
      return 'Données invalides.';
    }
  }

}
