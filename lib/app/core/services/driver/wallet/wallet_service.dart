import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';

abstract class WalletService {
  Future<ApiResult<Map<String, dynamic>>> fetchPaymentHistory();
}
