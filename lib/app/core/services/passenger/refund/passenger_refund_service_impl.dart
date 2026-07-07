import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/refund_model.dart';
import 'package:dio/dio.dart';
import 'passenger_refund_service.dart';

class PassengerRefundServiceImpl implements PassengerRefundService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<RefundContext>> fetchContext(String bookingUuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(
          AppApi.passengerRefundContext(bookingUuid), options: opts);
      logger.d('refundContext($bookingUuid) [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
            RefundContext.fromJson(res.data['body'] as Map<String, dynamic>));
      }
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('refundContext: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('refundContext: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<RefundResult>> submitRefund(
    String bookingUuid, {
    required String reason,
    String? description,
  }) async {
    try {
      final opts = await _authOptions();
      opts.contentType = 'multipart/form-data';
      final formData = FormData.fromMap({
        'reason': reason,
        if (description != null && description.isNotEmpty)
          'description': description,
      });
      final res = await _dio.post(
        AppApi.passengerRefundSubmit(bookingUuid),
        data: formData,
        options: opts,
      );
      logger.d('submitRefund($bookingUuid) [${res.statusCode}]');
      if (res.statusCode == 201 && res.data['success'] == true) {
        return ApiResult.success(
            RefundResult.fromJson(res.data['body'] as Map<String, dynamic>));
      }
      if (res.statusCode == 409) {
        return ApiResult.failure(AppError.refundAlreadySubmitted);
      }
      if (res.statusCode == 422) return ApiResult.failure(AppError.validationError);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('submitRefund: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('submitRefund: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<List<RefundHistoryItem>>> fetchHistory() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.passengerRefunds, options: opts);
      logger.d('passengerRefunds [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = res.data['body'] as List? ?? [];
        return ApiResult.success(
            list.map((j) => RefundHistoryItem.fromJson(j as Map<String, dynamic>))
                .toList());
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('passengerRefunds: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerRefunds: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }
}
