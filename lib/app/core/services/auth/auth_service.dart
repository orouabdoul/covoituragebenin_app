import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/auth_result.dart';

abstract class AuthService {
  Future<ApiResult<String?>> sendOtp({required String phone});
  Future<ApiResult<AuthResult>> verifyOtp({
    required String phone,
    required String otpCode,
  });
}
