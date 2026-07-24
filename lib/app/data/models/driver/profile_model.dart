class ProfileHeroData {
  const ProfileHeroData({
    required this.fullName,
    required this.phone,
    required this.badge,
    required this.level,
    required this.levelNumber,
    required this.location,
    required this.rating,
    required this.tripsCount,
    required this.tenureMonths,
    this.avatarUrl,
  });

  final String fullName;
  final String phone;
  final String badge;
  final String level;
  final int levelNumber;
  final String location;
  final double rating;
  final int tripsCount;
  final int tenureMonths;
  final String? avatarUrl;

  factory ProfileHeroData.fromJson(Map<String, dynamic> json) {
    final rawAvatar = (json['avatar_url'] as String?)?.trim() ??
        (json['selfie_url'] as String?)?.trim() ??
        (json['photo_url'] as String?)?.trim();
    return ProfileHeroData(
      fullName: (json['full_name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      badge: (json['badge'] as String?) ?? '',
      level: (json['level'] as String?) ?? '',
      levelNumber: (json['level_number'] as num?)?.toInt() ?? 1,
      location: (json['location'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      tripsCount: (json['trips_count'] as num?)?.toInt() ?? 0,
      tenureMonths: (json['tenure_months'] as num?)?.toInt() ?? 0,
      avatarUrl: (rawAvatar?.isNotEmpty == true) ? rawAvatar : null,
    );
  }
}

class ProfileVerificationItemData {
  const ProfileVerificationItemData({
    required this.key,
    required this.title,
    required this.status,
    required this.verified,
  });

  final String key;
  final String title;
  final String status;
  final bool verified;

  factory ProfileVerificationItemData.fromJson(Map<String, dynamic> json) =>
      ProfileVerificationItemData(
        key: (json['key'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        verified: (json['verified'] as bool?) ?? false,
      );
}

class ProfileStatData {
  const ProfileStatData({
    required this.key,
    required this.value,
    required this.label,
    required this.emphasized,
  });

  final String key;
  final String value;
  final String label;
  final bool emphasized;

  factory ProfileStatData.fromJson(Map<String, dynamic> json) => ProfileStatData(
        key: (json['key'] as String?) ?? '',
        value: (json['value'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
        emphasized: (json['emphasized'] as bool?) ?? false,
      );
}

class ProfilePersonalInfoData {
  const ProfilePersonalInfoData({
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.gender,
    required this.city,
    required this.neighborhood,
    required this.addressDetails,
    required this.memberSince,
  });

  final String firstName;
  final String lastName;
  final String fullName;
  final String phone;
  final String email;
  final String gender;
  final String city;
  final String neighborhood;
  final String addressDetails;
  final String memberSince;

  factory ProfilePersonalInfoData.fromJson(Map<String, dynamic> json) =>
      ProfilePersonalInfoData(
        firstName: (json['first_name'] as String?) ?? '',
        lastName: (json['last_name'] as String?) ?? '',
        fullName: (json['full_name'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
        gender: (json['gender'] as String?) ?? '',
        city: (json['city'] as String?) ?? '',
        neighborhood: (json['neighborhood'] as String?) ?? '',
        addressDetails: (json['address_details'] as String?) ?? '',
        memberSince: (json['member_since'] as String?) ?? '',
      );
}

class ProfileVehicleData {
  const ProfileVehicleData({
    required this.uuid,
    required this.brand,
    required this.model,
    required this.color,
    required this.year,
    required this.licensePlate,
    required this.availableSeats,
    required this.verificationStatus,
    required this.isActive,
    required this.vehicleType,
    required this.vehicleTypeSlug,
    required this.vehiclePhotoUrl,
  });

  final String uuid;
  final String brand;
  final String model;
  final String color;
  final int year;
  final String licensePlate;
  final int availableSeats;
  final String verificationStatus;
  final bool isActive;
  final String vehicleType;
  final String vehicleTypeSlug;
  final String vehiclePhotoUrl;

  factory ProfileVehicleData.fromJson(Map<String, dynamic> json) =>
      ProfileVehicleData(
        uuid: (json['uuid'] as String?) ?? '',
        brand: (json['brand'] as String?) ?? '',
        model: (json['model'] as String?) ?? '',
        color: (json['color'] as String?) ?? '',
        year: (json['year'] as num?)?.toInt() ?? 0,
        licensePlate: (json['license_plate'] as String?) ?? '',
        availableSeats: (json['available_seats'] as num?)?.toInt() ?? 0,
        verificationStatus: (json['verification_status'] as String?) ?? '',
        isActive: (json['is_active'] as bool?) ?? false,
        vehicleType: (json['vehicle_type'] as String?) ?? '',
        vehicleTypeSlug: (json['vehicle_type_slug'] as String?) ?? '',
        vehiclePhotoUrl: (json['vehicle_photo_url'] as String?) ?? '',
      );
}

class ProfileDocumentData {
  const ProfileDocumentData({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.hasFile,
    required this.url,
  });

  final String key;
  final String title;
  final String subtitle;
  final bool hasFile;
  final String url;

  factory ProfileDocumentData.fromJson(Map<String, dynamic> json) =>
      ProfileDocumentData(
        key: (json['key'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        subtitle: (json['subtitle'] as String?) ?? '',
        hasFile: (json['has_file'] as bool?) ?? false,
        url: (json['url'] as String?) ?? '',
      );
}

class ProfilePerformanceData {
  const ProfilePerformanceData({
    required this.currentLevel,
    required this.progress,
    required this.nextLevel,
    required this.tripsToNext,
    required this.badgesCount,
    required this.topPercent,
    required this.bonusCount,
  });

  final String currentLevel;
  final double progress;
  final String nextLevel;
  final int tripsToNext;
  final int badgesCount;
  final int topPercent;
  final int bonusCount;

  factory ProfilePerformanceData.fromJson(Map<String, dynamic> json) =>
      ProfilePerformanceData(
        currentLevel: (json['current_level'] as String?) ?? '',
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        nextLevel: (json['next_level'] as String?) ?? '',
        tripsToNext: (json['trips_to_next'] as num?)?.toInt() ?? 0,
        badgesCount: (json['badges_count'] as num?)?.toInt() ?? 0,
        topPercent: (json['top_percent'] as num?)?.toInt() ?? 0,
        bonusCount: (json['bonus_count'] as num?)?.toInt() ?? 0,
      );
}

class ProfilePreferencesData {
  const ProfilePreferencesData({
    required this.autoAvailability,
    required this.notificationsEnabled,
  });

  final bool autoAvailability;
  final bool notificationsEnabled;

  factory ProfilePreferencesData.fromJson(Map<String, dynamic> json) =>
      ProfilePreferencesData(
        autoAvailability: (json['auto_availability'] as bool?) ?? false,
        notificationsEnabled: (json['notifications_enabled'] as bool?) ?? true,
      );
}

class ProfileModel {
  const ProfileModel({
    required this.hero,
    required this.verificationItems,
    required this.stats,
    required this.personalInfo,
    required this.vehicles,
    required this.documents,
    required this.performance,
    required this.preferences,
    required this.emergencyContacts,
  });

  final ProfileHeroData hero;
  final List<ProfileVerificationItemData> verificationItems;
  final List<ProfileStatData> stats;
  final ProfilePersonalInfoData personalInfo;
  final List<ProfileVehicleData> vehicles;
  final List<ProfileDocumentData> documents;
  final ProfilePerformanceData performance;
  final ProfilePreferencesData preferences;
  final List<Map<String, dynamic>> emergencyContacts;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        hero: ProfileHeroData.fromJson(
            (json['hero'] as Map<String, dynamic>?) ?? {}),
        verificationItems: (json['verification_items'] as List?)
                ?.map((v) => ProfileVerificationItemData.fromJson(
                    v as Map<String, dynamic>))
                .toList() ??
            [],
        stats: (json['stats'] as List?)
                ?.map((s) =>
                    ProfileStatData.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        personalInfo: ProfilePersonalInfoData.fromJson(
            (json['personal_info'] as Map<String, dynamic>?) ?? {}),
        vehicles: (json['vehicles'] as List?)
                ?.map((v) =>
                    ProfileVehicleData.fromJson(v as Map<String, dynamic>))
                .toList() ??
            [],
        documents: (json['documents'] as List?)
                ?.map((d) =>
                    ProfileDocumentData.fromJson(d as Map<String, dynamic>))
                .toList() ??
            [],
        performance: ProfilePerformanceData.fromJson(
            (json['performance'] as Map<String, dynamic>?) ?? {}),
        preferences: ProfilePreferencesData.fromJson(
            (json['preferences'] as Map<String, dynamic>?) ?? {}),
        emergencyContacts: (json['emergency_contacts'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            [],
      );
}
