import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/messenger_model.dart';
import 'package:dio/dio.dart';
import 'passenger_messaging_service.dart';

class PassengerMessagingServiceImpl implements PassengerMessagingService {
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
        AppApi.passengerMessager,
        queryParameters: {'filter': filter},
        options: opts,
      );
      logger.d('passengerMessager[$filter] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final raw = res.data['body'];
        final body = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
        return ApiResult.success(MessengerInboxModel.fromJson(body));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('passengerMessager fetchInbox: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerMessager fetchInbox: $e');
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
        AppApi.passengerConversationThread(uuid),
        queryParameters: params,
        options: opts,
      );
      logger.d('passengerFetchThread[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final raw = res.data['body'];
        final body = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
        return ApiResult.success(ConversationThreadDetail.fromJson(body));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('passengerFetchThread: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerFetchThread: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<ConversationApiMessage>> sendAttachment(
      String uuid, String filePath, {String? caption}) async {
    try {
      final opts = await _authOptions();
      final formData = FormData.fromMap({
        if (caption != null && caption.isNotEmpty) 'body': caption,
        'attachment': await MultipartFile.fromFile(filePath),
      });
      final res = await _dio.post(
        AppApi.conversationMessages(uuid),
        data: formData,
        options: Options(
          validateStatus: (_) => true,
          headers: {
            'Authorization': opts.headers?['Authorization'],
          },
        ),
      );
      logger.d('passengerSendAttachment[$uuid] [${res.statusCode}]');
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
      logger.e('passengerSendAttachment: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerSendAttachment: $e');
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
        data: {'body': message},
        options: opts,
      );
      logger.d('passengerSendMessage[$uuid] [${res.statusCode}]');
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
      logger.e('passengerSendMessage: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerSendMessage: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<String>> startConversation(String bookingUuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.bookingStartConversation(bookingUuid),
        options: opts,
      );
      logger.d('startConversation[$bookingUuid] [${res.statusCode}]');
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data['success'] == true) {
        final uuid = res.data['body']?['conversation_uuid'] as String? ?? '';
        if (uuid.isEmpty) return ApiResult.failure(AppError.unexpected);
        return ApiResult.success(uuid);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('startConversation: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('startConversation: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> markAsRead(String uuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(AppApi.conversationRead(uuid), options: opts);
      logger.d('passengerMarkAsRead[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200) return ApiResult.success(null);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('passengerMarkAsRead: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerMarkAsRead: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }
}
