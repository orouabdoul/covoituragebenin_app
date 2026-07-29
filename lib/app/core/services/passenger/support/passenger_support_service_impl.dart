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

  @override
  Future<ApiResult<SupportTicket>> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.passengerSupportTickets,
        data: {
          'subject': subject,
          'description': description,
          'category': category,
          'priority': priority,
        },
        options: opts,
      );
      logger.d('createSupportTicket [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 422) return ApiResult.failure(AppError.validationError);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          final ticketJson = body['ticket'] is Map<String, dynamic>
              ? body['ticket'] as Map<String, dynamic>
              : body;
          return ApiResult.success(SupportTicket.fromJson(ticketJson));
        }
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
}
