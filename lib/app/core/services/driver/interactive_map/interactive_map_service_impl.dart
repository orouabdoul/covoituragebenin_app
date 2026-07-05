import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/interactive_map_model.dart';
import 'package:dio/dio.dart';
import 'interactive_map_service.dart';

class InteractiveMapServiceImpl implements InteractiveMapService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<MapDataModel>> fetchMapData(String uuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.driverTripMap(uuid), options: opts);
      logger.d('fetchMapData[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
          MapDataModel.fromJson(res.data['body'] as Map<String, dynamic>),
        );
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('fetchMapData: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('fetchMapData: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<StopDoneResult>> markStopDone(
      String tripUuid, String bookingUuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.driverTripStopDone(tripUuid, bookingUuid),
        options: opts,
      );
      logger.d('markStopDone[$tripUuid/$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
          StopDoneResult.fromJson(res.data['body'] as Map<String, dynamic>),
        );
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('markStopDone: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('markStopDone: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<RecalculateResult>> recalculate(String uuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(AppApi.driverTripRecalculate(uuid), options: opts);
      logger.d('recalculate[$uuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
          RecalculateResult.fromJson(res.data['body'] as Map<String, dynamic>),
        );
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('recalculate: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('recalculate: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

}
