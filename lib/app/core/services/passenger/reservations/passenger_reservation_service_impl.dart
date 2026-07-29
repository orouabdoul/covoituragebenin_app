import 'dart:convert';

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
      final statusCode = res.statusCode ?? 0;
      logger.d('confirmationContext[$tripUuid] [$statusCode]');
      if (statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (statusCode == 404) return ApiResult.failure(AppError.tripNotFound);
      if (statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          return ApiResult.success(ConfirmationContextModel.fromJson(body));
        }
      }
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
  Future<ApiResult<CreateBookingResult>> createBooking(
    String tripUuid, {
    required int seats,
    required String pickupCity,
    required String pickupNeighborhood,
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String dropoffCity,
    required String dropoffNeighborhood,
    required String dropoffAddress,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(
        AppApi.createBooking(tripUuid),
        data: {
          'seats_booked': seats,
          'pickup_city': pickupCity,
          'pickup_neighborhood': pickupNeighborhood,
          'pickup_address': pickupAddress,
          'pickup_latitude': pickupLat,
          'pickup_longitude': pickupLng,
          'dropoff_city': dropoffCity,
          'dropoff_neighborhood': dropoffNeighborhood,
          'dropoff_address': dropoffAddress,
          'dropoff_latitude': dropoffLat,
          'dropoff_longitude': dropoffLng,
        },
        options: opts,
      );
      final statusCode = res.statusCode ?? 0;
      logger.d('createBooking[$tripUuid] [$statusCode]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.tripNotFound);
      if (res.statusCode == 409) {
        final msg = res.data is Map ? res.data['message'] as String? : null;
        return ApiResult.failure(AppError.unexpected,
            message: msg ?? 'Vous avez déjà une réservation pour ce trajet.');
      }
      if (res.statusCode == 422) {
        final msg = res.data is Map ? res.data['message'] as String? : null;
        return ApiResult.failure(AppError.tripDataInvalid, message: msg);
      }
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data is Map &&
          res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          return ApiResult.success(CreateBookingResult.fromJson(body));
        }
      }
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
  Future<ApiResult<void>> cancelBooking(String bookingUuid) async {
    try {
      final opts = await _authOptions();
      final res = await _dio.post(AppApi.cancelBooking(bookingUuid), options: opts);
      logger.d('cancelBooking[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.tripNotFound);
      if (res.statusCode == 422) return ApiResult.failure(AppError.tripDataInvalid);
      if (res.statusCode == 200) return ApiResult.success(null);
      return ApiResult.failure(AppError.unexpected);
    } on DioException catch (e) {
      logger.e('cancelBooking: $e');
      return ApiResult.failure(AppDio.classifyDioError(e));
    } catch (e) {
      logger.e('cancelBooking: $e');
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
        data: {'phone_number': phone, 'provider': provider},
        options: opts,
      );
      logger.d('initiatePayment[$bookingUuid] [${res.statusCode}]');
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (res.data is Map && res.data['success'] == false) {
          logger.e('initiatePayment failed: ${res.data['message']}');
          return ApiResult.failure(AppError.unexpected);
        }
        return ApiResult.success(null);
      }
      // 409 = paiement déjà effectué → traiter comme succès
      if (res.statusCode == 409) {
        logger.d('initiatePayment[$bookingUuid] already paid, treating as success');
        return ApiResult.success(null);
      }
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 422) return ApiResult.failure(AppError.validationError);
      if (res.statusCode == 500) return ApiResult.failure(AppError.paymentProviderError);
      // 502 = FedaPay a rejeté la demande (mauvais numéro, réseau incorrect, sandbox…)
      if (res.statusCode == 502) {
        final msg = res.data is Map ? res.data['message'] as String? : null;
        logger.e('initiatePayment 502: $msg');
        return ApiResult.failure(AppError.paymentProviderError, message: msg);
      }
      logger.e('initiatePayment unexpected status ${res.statusCode}: ${res.data}');
      final fallbackMsg = res.data is Map ? res.data['message'] as String? : null;
      return ApiResult.failure(AppError.unexpected, message: fallbackMsg);
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
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.tripNotFound);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          return ApiResult.success(ApprovalStatusModel.fromJson(body));
        }
      }
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
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.tripNotFound);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          return ApiResult.success(PaymentSuccessModel.fromJson(body));
        }
      }
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
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          return ApiResult.success(ReservationsPageModel.fromJson(body));
        }
      }
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
      final sc = res.statusCode ?? 0;
      logger.d('invoice[$bookingUuid] [$sc] body=${res.data}');
      if (sc == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (sc == 403) return ApiResult.failure(AppError.permissionDenied);
      if (sc == 404) return ApiResult.failure(AppError.tripNotFound);
      if (sc == 200) {
        try {
          // Normalise res.data en Map<String, dynamic> quel que soit le type retourné par Dio
          Map<String, dynamic> root;
          final raw = res.data;
          logger.d('invoice type=${raw?.runtimeType}');
          if (raw is Map<String, dynamic>) {
            root = raw;
          } else if (raw is Map) {
            root = Map<String, dynamic>.from(raw);
          } else if (raw is String) {
            root = Map<String, dynamic>.from(jsonDecode(raw) as Map);
          } else {
            logger.e('invoice: inattendu type=${raw?.runtimeType}');
            return ApiResult.failure(AppError.unexpected);
          }

          // Le backend enveloppe dans { success, body: {...} }
          final rawBody = root['body'];
          Map<String, dynamic> body;
          if (rawBody is Map<String, dynamic>) {
            body = rawBody;
          } else if (rawBody is Map) {
            body = Map<String, dynamic>.from(rawBody);
          } else if (root.containsKey('invoice_ref')) {
            body = root; // champs à la racine
          } else {
            logger.e('invoice: body manquant root=$root');
            return ApiResult.failure(AppError.unexpected);
          }

          logger.d('invoice: ok keys=${body.keys.toList()}');
          return ApiResult.success(InvoiceModel.fromJson(body));
        } catch (e, st) {
          logger.e('invoice parse: $e\n$st');
          return ApiResult.failure(AppError.unexpected);
        }
      }
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
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 403) return ApiResult.failure(AppError.permissionDenied);
      if (res.statusCode == 404) return ApiResult.failure(AppError.tripNotFound);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          return ApiResult.success(LiveTrackingModel.fromJson(body));
        }
      }
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
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 404) return ApiResult.failure(AppError.tripNotFound);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          return ApiResult.success(TripConfirmationContextModel.fromJson(body));
        }
      }
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
      final sc = res.statusCode ?? 0;
      logger.d('confirmTrip[$bookingUuid] [$sc] body=${res.data}');
      if (sc == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (sc == 404) return ApiResult.failure(AppError.tripNotFound);
      if (sc >= 200 && sc < 300) return ApiResult.success(null);
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
        data: {
          'rating': rating,
          'tags': tags,
          if (comment.isNotEmpty) 'comment': comment,
        },
        options: opts,
      );
      final sc2 = res.statusCode ?? 0;
      logger.d('submitReview[$bookingUuid] [$sc2] body=${res.data}');
      if (sc2 == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (sc2 == 404) return ApiResult.failure(AppError.tripNotFound);
      if (sc2 == 422) return ApiResult.failure(AppError.validationError);
      if (sc2 >= 200 && sc2 < 300) return ApiResult.success(null);
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
      if (res.statusCode == 401) return ApiResult.failure(AppError.unAuthenticated);
      if (res.statusCode == 404) return ApiResult.failure(AppError.tripNotFound);
      if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
        final body = res.data['body'];
        if (body is Map<String, dynamic>) {
          return ApiResult.success(TripDetailModel.fromJson(body));
        }
      }
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
