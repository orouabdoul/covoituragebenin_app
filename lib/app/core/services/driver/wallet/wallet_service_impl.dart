import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'wallet_service.dart';

class WalletServiceImpl implements WalletService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> fetchPaymentHistory() async {
    try {
      final opts = await _authOptions();
      final response =
          await _dio.get(AppApi.driverPaymentHistory, options: opts);
      logger.d('paymentHistory [${response.statusCode}]');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResult.success(
            response.data['body'] as Map<String, dynamic>);
      }
      if (response.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('paymentHistory: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('paymentHistory: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

}
