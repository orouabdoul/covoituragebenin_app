import 'user_model.dart';

class AuthResult {
  final String token;
  final bool profileComplete;
  final bool isVerified;
  final UserModel user;

  const AuthResult({
    required this.token,
    required this.profileComplete,
    required this.isVerified,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String? ?? '',
      profileComplete: json['profile_complete'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
