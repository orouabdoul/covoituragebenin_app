import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/refund_model.dart';

abstract class PassengerRefundService {
  Future<ApiResult<RefundContext>> fetchContext(String bookingUuid);
  Future<ApiResult<RefundResult>> submitRefund(
    String bookingUuid, {
    required String reason,
    String? description,
  });
  Future<ApiResult<List<RefundHistoryItem>>> fetchHistory();
}
