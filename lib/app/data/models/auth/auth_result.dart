import 'user_model.dart';

class AuthResult {
  /// Token de session (utilisateur existant) ou vide si nouveau compte.
  final String token;

  /// Token temporaire (20 min) pour compléter l'inscription.
  /// Non-null uniquement quand [isNewUser] == true.
  final String? registerToken;

  final bool isNewUser;
  final bool profileComplete;
  final bool isVerified;

  /// Null pour les nouveaux comptes (pas encore créés en base).
  final UserModel? user;

  const AuthResult({
    this.token = '',
    this.registerToken,
    this.isNewUser = false,
    required this.profileComplete,
    this.isVerified = false,
    this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final isNewUser = json['is_new_user'] as bool? ?? false;
    if (isNewUser) {
      return AuthResult(
        registerToken: json['register_token'] as String?,
        isNewUser: true,
        profileComplete: false,
      );
    }
    return AuthResult(
      token: json['token'] as String? ?? '',
      profileComplete: json['profile_complete'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
