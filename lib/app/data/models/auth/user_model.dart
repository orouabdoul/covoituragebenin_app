class UserModel {
  final int id;
  final String uuid;
  final String phone;
  final bool isVerified;
  final bool isBlocked;
  final int penaltyPoints;
  final String role;

  const UserModel({
    required this.id,
    required this.uuid,
    required this.phone,
    required this.isVerified,
    required this.isBlocked,
    required this.penaltyPoints,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      isBlocked: json['is_blocked'] as bool? ?? false,
      penaltyPoints: json['penalty_points'] as int? ?? 0,
      role: json['role'] as String? ?? '',
    );
  }
}
