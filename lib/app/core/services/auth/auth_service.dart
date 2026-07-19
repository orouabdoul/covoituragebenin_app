import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/data/models/auth/auth_result.dart';
import 'package:covoiturage_benin_app/app/data/models/auth/otp_send_result.dart';

export 'package:covoiturage_benin_app/app/data/models/auth/otp_send_result.dart';

abstract class AuthService {
  Future<ApiResult<OtpSendResult>> sendOtp({required String phone});
  Future<ApiResult<AuthResult>> verifyOtp({
    required String phone,
    required String otpCode,
  });
  /// Révoque le token Sanctum de la session courante.
  Future<ApiResult<void>> logout();
  /// Retourne les données complètes de l'utilisateur authentifié.
  Future<ApiResult<AuthResult>> me();
  /// Assigne le rôle de l'utilisateur côté serveur (driver | passenger).
  Future<ApiResult<void>> setUserRole(String role);
}
