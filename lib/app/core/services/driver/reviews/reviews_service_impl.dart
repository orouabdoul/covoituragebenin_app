import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/review_model.dart';
import 'package:dio/dio.dart';
import 'reviews_service.dart';

class ReviewsServiceImpl implements ReviewsService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<ReviewsBodyModel>> fetchReviews({int page = 1}) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(
        AppApi.driverReviews,
        queryParameters: {'page': page},
        options: opts,
      );
      logger.d('fetchReviews[page=$page] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
          ReviewsBodyModel.fromJson(res.data['body'] as Map<String, dynamic>),
        );
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('fetchReviews: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('fetchReviews: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> replyToReview(String uuid, String reply) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.driverReviewReply(uuid),
        data: {'reply': reply},
        options: opts,
      );
      logger.d('replyToReview[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200) return ApiResult.success(null);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 404) return ApiResult.failure(AppError.unexpected);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('replyToReview: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('replyToReview: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

}
