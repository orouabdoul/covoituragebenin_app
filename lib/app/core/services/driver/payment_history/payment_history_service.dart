import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/wallet_model.dart';

abstract class PaymentHistoryService {
  Future<ApiResult<PaymentHistoryBodyModel>> fetchHistory({
    String filter = 'all',
  });
  Future<ApiResult<void>> fetchReceipt();
}
