import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';

abstract class WithdrawService {
  String? get lastValidationMessage;
  Future<ApiResult<Map<String, dynamic>>> fetchWallet();
  Future<ApiResult<Map<String, dynamic>>> withdraw({
    required int amount,
    required String provider,
    required String phoneNumber,
  });
}
