import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/home_model.dart';
import 'package:dio/dio.dart';
import 'home_service.dart';

class PassengerHomeServiceImpl implements PassengerHomeService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<PassengerHomeDashboard>> fetchDashboard() async {
    try {
      final opts = await _authOptions();
      final response = await _dio.get(AppApi.passengerHome, options: opts);
      logger.d('passengerHome [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final body = response.data['body'] as Map<String, dynamic>;
        return ApiResult.success(PassengerHomeDashboard.fromJson(body));
      }
      if (response.statusCode == 401) {
        return ApiResult.failure(AppError.unAuthenticated);
      }
      if (response.statusCode == 403) {
        return ApiResult.failure(AppError.permissionDenied);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('passengerHome: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerHome: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }
}
