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

  Future<String> _bearerToken() async {
    final token = await UserController.instance.getSessionToken();
    return 'Bearer $token';
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
        final raw = res.data['body'];
        final body = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
        return ApiResult.success(MessengerInboxModel.fromJson(body));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverFetchInbox: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverFetchInbox: $e');
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
      logger.d('driverFetchThread[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final raw = res.data['body'];
        final body = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
        return ApiResult.success(ConversationThreadDetail.fromJson(body));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.unexpected);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverFetchThread: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverFetchThread: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<ConversationApiMessage>> sendMessage(
    String uuid,
    String message,
  ) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.driverConversationMessages(uuid),
        data: {'body': message},
        options: opts,
      );
      logger.d('driverSendMessage[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (res.data['success'] == true) {
          final raw = res.data['body'];
          final body = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
          return ApiResult.success(ConversationApiMessage.fromJson(body));
        }
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverSendMessage: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverSendMessage: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<ConversationApiMessage>> sendAttachment(
    String uuid,
    String filePath, {
    String? caption,
  }) async {
    try {
      final bearer = await _bearerToken();
      final formData = FormData.fromMap({
        if (caption != null && caption.isNotEmpty) 'body': caption,
        'attachment': await MultipartFile.fromFile(filePath),
      });
      final res = await _dio.post(
        AppApi.driverConversationMessages(uuid),
        data: formData,
        options: Options(
          validateStatus: (_) => true,
          headers: {'Authorization': bearer},
        ),
      );
      logger.d('driverSendAttachment[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (res.data['success'] == true) {
          final raw = res.data['body'];
          final body = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
          return ApiResult.success(ConversationApiMessage.fromJson(body));
        }
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 422) return ApiResult.failure(AppError.unexpected);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverSendAttachment: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverSendAttachment: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> markAsRead(String uuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(AppApi.driverConversationRead(uuid), options: opts);
      logger.d('driverMarkAsRead[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200) return ApiResult.success(null);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverMarkAsRead: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverMarkAsRead: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<String>> startConversation(String bookingUuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.driverBookingStartConversation(bookingUuid),
        options: opts,
      );
      logger.d('driverStartConversation[$bookingUuid] [${res.statusCode}]');
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data['success'] == true) {
        final uuid = res.data['body']?['conversation_uuid'] as String? ?? '';
        if (uuid.isEmpty) return ApiResult.failure(AppError.unexpected);
        return ApiResult.success(uuid);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverStartConversation: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverStartConversation: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> deleteMessage(String messageUuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.delete(
        AppApi.driverMessageDelete(messageUuid),
        options: opts,
      );
      logger.d('driverDeleteMessage[$messageUuid] [${res.statusCode}]');
      if (res.statusCode == 200) return ApiResult.success(null);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.unexpected);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverDeleteMessage: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverDeleteMessage: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> editMessage(String messageUuid, String newBody) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.patch(
        AppApi.driverMessageEdit(messageUuid),
        data: {'body': newBody},
        options: opts,
      );
      logger.d('driverEditMessage[$messageUuid] [${res.statusCode}]');
      if (res.statusCode == 200) return ApiResult.success(null);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.unexpected);
      if (res.statusCode == 422) return ApiResult.failure(AppError.unexpected);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('driverEditMessage: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('driverEditMessage: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }
}
