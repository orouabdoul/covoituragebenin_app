import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/safety_model.dart';
import 'package:dio/dio.dart';
import 'passenger_safety_service.dart';

class PassengerSafetyServiceImpl implements PassengerSafetyService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<SafetyContext>> fetchContext() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.passengerSafety, options: opts);
      logger.d('passengerSafety [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          return ApiResult.success(SafetyContext.fromJson(body));
        }
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<bool>> activateSOS() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(AppApi.passengerSafetySos, options: opts);
      logger.d('activateSOS [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        return ApiResult.success(true);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<bool>> cancelSOS() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.delete(AppApi.passengerSafetySos, options: opts);
      logger.d('cancelSOS [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        return ApiResult.success(true);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<String>> startTripShare() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(AppApi.passengerSafetyTripShare, options: opts);
      logger.d('startTripShare [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          final code = (body['code'] ?? '').toString();
          return ApiResult.success(code);
        }
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<bool>> stopTripShare() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.delete(AppApi.passengerSafetyTripShare, options: opts);
      logger.d('stopTripShare [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        return ApiResult.success(true);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<List<EmergencyContact>>> fetchContacts() async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(AppApi.passengerSafetyContacts, options: opts);
      logger.d('fetchContacts [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        final raw = body is List
            ? body
            : body is Map
                ? (body['emergency_contacts'] ?? body['contacts'] ?? body['data'] ?? [])
                : [];
        final list = raw as List;
        return ApiResult.success(
            list.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>)).toList());
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<EmergencyContact>> addContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.passengerSafetyContacts,
        data: {'name': name, 'phone': phone, 'relation': relation},
        options: opts,
      );
      logger.d('addContact [${res.statusCode}]');
      if (res.statusCode == 422) return ApiResult.failure(AppError.validationError);
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data is Map &&
          res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          final contact = body['contact'];
          if (contact is Map<String, dynamic>) {
            return ApiResult.success(EmergencyContact.fromJson(contact));
          }
          return ApiResult.success(EmergencyContact.fromJson(body));
        }
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<bool>> deleteContact(String id) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.delete(AppApi.passengerSafetyContact(id), options: opts);
      logger.d('deleteContact($id) [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.tripNotFound);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        return ApiResult.success(true);
      }
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      return ApiResult.failure(AppError.unexpected);
    }
  }
}
