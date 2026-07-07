import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reservations_model.dart';
import 'package:dio/dio.dart';
import 'passenger_reservation_service.dart';

class PassengerReservationServiceImpl implements PassengerReservationService {
  final Dio _dio = AppDio.create();

  Future<Options> _authOptions() async {
    final token = await UserController.instance.getSessionToken();
    return Options(
      validateStatus: (_) => true,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<ApiResult<ConfirmationContextModel>> fetchConfirmationContext(
      String tripUuid) async {
    try {
      final opts = await _authOptions();
      final res =
          await _dio.get(AppApi.passengerTripConfirmationCtx(tripUuid), options: opts);
      logger.d('confirmationContext[$tripUuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
            ConfirmationContextModel.fromJson(res.data['body'] as Map<String, dynamic>));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('confirmationContext: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('confirmationContext: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<String>> createBooking(String tripUuid,
      {required int seats}) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.createBooking(tripUuid),
        data: {'seats': seats},
        options: opts,
      );
      logger.d('createBooking[$tripUuid] [${res.statusCode}]');
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data['success'] == true) {
        final bookingUuid =
            (res.data['body'] as Map<String, dynamic>?)?['booking_uuid'] as String? ?? '';
        return ApiResult.success(bookingUuid);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('createBooking: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('createBooking: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> initiatePayment(String bookingUuid,
      {required String phone, required String provider}) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.initiateBookingPayment(bookingUuid),
        data: {'phone': phone, 'provider': provider},
        options: opts,
      );
      logger.d('initiatePayment[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 200 || res.statusCode == 201) {
        return ApiResult.success(null);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('initiatePayment: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('initiatePayment: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<ApprovalStatusModel>> fetchApprovalStatus(
      String bookingUuid) async {
    try {
      final opts = await _authOptions();
      final res =
          await _dio.get(AppApi.passengerBookingApprovalStatus(bookingUuid), options: opts);
      logger.d('approvalStatus[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
            ApprovalStatusModel.fromJson(res.data['body'] as Map<String, dynamic>));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('approvalStatus: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('approvalStatus: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<PaymentSuccessModel>> fetchPaymentSuccess(
      String bookingUuid) async {
    try {
      final opts = await _authOptions();
      final res =
          await _dio.get(AppApi.passengerBookingSuccess(bookingUuid), options: opts);
      logger.d('paymentSuccess[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
            PaymentSuccessModel.fromJson(res.data['body'] as Map<String, dynamic>));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('paymentSuccess: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('paymentSuccess: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<ReservationsPageModel>> fetchReservations(
      {String? status}) async {
    try {
      final opts = await _authOptions();
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      final res = await _dio.get(
        AppApi.passengerReservationsList,
        queryParameters: params.isEmpty ? null : params,
        options: opts,
      );
      logger.d('passengerReservations[${status ?? 'all'}] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
            ReservationsPageModel.fromJson(res.data['body'] as Map<String, dynamic>));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('passengerReservations: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('passengerReservations: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<InvoiceModel>> fetchInvoice(String bookingUuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(
          AppApi.passengerReservationInvoice(bookingUuid), options: opts);
      logger.d('invoice[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
            InvoiceModel.fromJson(res.data['body'] as Map<String, dynamic>));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('invoice: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('invoice: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<LiveTrackingModel>> fetchLiveTracking(String tripUuid) async {
    try {
      final opts = await _authOptions();
      final res =
          await _dio.get(AppApi.passengerTripLiveTracking(tripUuid), options: opts);
      logger.d('liveTracking[$tripUuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
            LiveTrackingModel.fromJson(res.data['body'] as Map<String, dynamic>));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('liveTracking: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('liveTracking: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<TripConfirmationContextModel>> fetchTripConfirmationContext(
      String bookingUuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.get(
          AppApi.passengerBookingTripConfirmationCtx(bookingUuid), options: opts);
      logger.d('tripConfirmationCtx[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(TripConfirmationContextModel.fromJson(
            res.data['body'] as Map<String, dynamic>));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('tripConfirmationCtx: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('tripConfirmationCtx: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> confirmTrip(String bookingUuid,
      {List<String> issues = const []}) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.passengerBookingConfirm(bookingUuid),
        data: {'issues': issues},
        options: opts,
      );
      logger.d('confirmTrip[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(null);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('confirmTrip: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('confirmTrip: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<void>> submitReview(
    String bookingUuid, {
    required int rating,
    required List<String> tags,
    String comment = '',
  }) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.passengerBookingReview(bookingUuid),
        data: {'rating': rating, 'tags': tags, 'comment': comment},
        options: opts,
      );
      logger.d('submitReview[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(null);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      if (res.statusCode == 422) return ApiResult.failure(AppError.validationError);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('submitReview: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('submitReview: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }

  @override
  Future<ApiResult<TripDetailModel>> fetchTripDetail(String tripUuid) async {
    try {
      final opts = await _authOptions();
      final res =
          await _dio.get(AppApi.passengerTripDetail(tripUuid), options: opts);
      logger.d('tripDetail[$tripUuid] [${res.statusCode}]');
      if (res.statusCode == 200 && res.data['success'] == true) {
        return ApiResult.success(
            TripDetailModel.fromJson(res.data['body'] as Map<String, dynamic>));
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 404) return ApiResult.failure(AppError.userNotFound);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('tripDetail: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('tripDetail: $e');
      return ApiResult.failure(AppError.unexpected);
    }
  }
}
