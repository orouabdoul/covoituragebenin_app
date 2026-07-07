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
      if (res.statusCode == 200 && res.data['success'] == true) {
        final topics = res.data['body']['topics'] as List? ?? [];
        final faqs = <FaqItem>[];
        for (final t in topics) {
          final label = (t['label'] ?? t['key'] ?? '').toString();
          for (final item in (t['items'] as List? ?? [])) {
            faqs.add(FaqItem(
              question: (item['question'] ?? '').toString(),
              answer: (item['answer'] ?? '').toString(),
              category: label,
            ));
          }
        }
        return ApiResult.success(faqs);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
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
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = res.data['body']['tickets'] as List? ?? [];
        return ApiResult.success(
            list.map((j) => SupportTicket.fromJson(j as Map<String, dynamic>)).toList());
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
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
      if (res.statusCode == 200 && res.data['success'] == true) {
        final ticketJson =
            res.data['body']['ticket'] as Map<String, dynamic>? ?? {};
        return ApiResult.success(SupportTicket.fromJson(ticketJson));
      }
      if (res.statusCode == 422) return ApiResult.failure(AppError.validationError);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
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
