import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/messenger_model.dart';
import 'package:dio/dio.dart';
import 'messaging_service.dart';

class MessagingServiceImpl implements MessagingService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<MessengerInboxModel>> fetchInbox({String filter = 'all'}) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(
        AppApi.driverMessager,
        queryParameters: {'filter': filter},
        options: opts,
      );
      logger.d('driverMessager[$filter] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
          MessengerInboxModel.fromJson(res.data['body'] as Map<String, dynamic>),
        );
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('fetchInbox: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('fetchInbox: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<ConversationThreadDetail>> fetchThread(
    String uuid, {
    int? beforeId,
    int perPage = 20,
  }) async {
    try {
      final opts = await _authOptions();
      final params = <String, dynamic>{'per_page': perPage};
      if (beforeId != null) params['before_id'] = beforeId;
      final res = await _dio.get(
        AppApi.driverConversationThread(uuid),
        queryParameters: params,
        options: opts,
      );
      logger.d('fetchThread[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
          ConversationThreadDetail.fromJson(res.data['body'] as Map<String, dynamic>),
        );
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('fetchThread: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('fetchThread: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<ConversationApiMessage>> sendMessage(
      String uuid, String message) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.conversationMessages(uuid),
        data: {'message': message},
        options: opts,
      );
      logger.d('sendMessage[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (res.data['success'] == true) {
          return ApiResult.success(
            ConversationApiMessage.fromJson(
              res.data['body'] as Map<String, dynamic>? ?? {},
            ),
          );
        }
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('sendMessage: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('sendMessage: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> markAsRead(String uuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(AppApi.conversationRead(uuid), options: opts);
      logger.d('markAsRead[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200) return ApiResult.success(null);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('markAsRead: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('markAsRead: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

}
