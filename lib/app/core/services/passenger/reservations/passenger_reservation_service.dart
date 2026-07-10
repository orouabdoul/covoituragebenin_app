import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reservations_model.dart';

abstract class PassengerReservationService {
  Future<ApiResult<ConfirmationContextModel>> fetchConfirmationContext(String tripUuid);

  Future<ApiResult<String>> createBooking(String tripUuid, {required int seats});

  Future<ApiResult<void>> cancelBooking(String bookingUuid);

  Future<ApiResult<void>> initiatePayment(
    String bookingUuid, {
    required String phone,
    required String provider,
  });

  Future<ApiResult<ApprovalStatusModel>> fetchApprovalStatus(String bookingUuid);

  Future<ApiResult<PaymentSuccessModel>> fetchPaymentSuccess(String bookingUuid);

  Future<ApiResult<ReservationsPageModel>> fetchReservations({String? status});

  Future<ApiResult<InvoiceModel>> fetchInvoice(String bookingUuid);

  Future<ApiResult<LiveTrackingModel>> fetchLiveTracking(String tripUuid);

  Future<ApiResult<TripConfirmationContextModel>> fetchTripConfirmationContext(
      String bookingUuid);

  Future<ApiResult<void>> confirmTrip(String bookingUuid,
      {List<String> issues = const []});

  Future<ApiResult<void>> submitReview(
    String bookingUuid, {
    required int rating,
    required List<String> tags,
    String comment = '',
  });

  Future<ApiResult<TripDetailModel>> fetchTripDetail(String tripUuid);
}
