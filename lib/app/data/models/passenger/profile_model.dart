class PassengerProfileSummaryData {
  const PassengerProfileSummaryData({
    required this.avatarUrl,
    required this.name,
    required this.phone,
    required this.isVerified,
    this.email = '',
    this.city = '',
    this.neighborhood = '',
  });

  final String avatarUrl;
  final String name;
  final String phone;
  final bool isVerified;
  final String email;
  final String city;
  final String neighborhood;

  factory PassengerProfileSummaryData.fromJson(Map<String, dynamic> json) =>
      PassengerProfileSummaryData(
        avatarUrl: (json['avatar_url'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
        isVerified: (json['is_verified'] as bool?) ?? false,
        email: (json['email'] as String?) ?? '',
        city: (json['city'] as String?) ?? '',
        neighborhood: (json['neighborhood'] as String?) ?? '',
      );
}

class PassengerProfileMetricData {
  const PassengerProfileMetricData({
    required this.key,
    required this.value,
    required this.label,
  });

  final String key;
  final String value;
  final String label;

  factory PassengerProfileMetricData.fromJson(Map<String, dynamic> json) =>
      PassengerProfileMetricData(
        key: (json['key'] as String?) ?? '',
        value: (json['value'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
      );
}

class PassengerTrustItemData {
  const PassengerTrustItemData({
    required this.key,
    required this.title,
    required this.status,
    required this.verified,
  });

  final String key;
  final String title;
  final String status;
  final bool verified;

  factory PassengerTrustItemData.fromJson(Map<String, dynamic> json) =>
      PassengerTrustItemData(
        key: (json['key'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        verified: (json['verified'] as bool?) ?? false,
      );
}

class PassengerTrustData {
  const PassengerTrustData({
    required this.title,
    required this.level,
    required this.verifiedNumber,
    required this.identityDocument,
    required this.verifiedEmail,
    required this.items,
  });

  final String title;
  final String level;
  final String verifiedNumber;
  final String identityDocument;
  final String verifiedEmail;
  final List<PassengerTrustItemData> items;

  factory PassengerTrustData.fromJson(Map<String, dynamic> json) =>
      PassengerTrustData(
        title: (json['title'] as String?) ?? '',
        level: (json['level'] as String?) ?? '',
        verifiedNumber: (json['verified_number'] as String?) ?? '',
        identityDocument: (json['identity_document'] as String?) ?? '',
        verifiedEmail: (json['verified_email'] as String?) ?? '',
        items: (json['items'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((i) => PassengerTrustItemData.fromJson(i))
            .toList(),
      );
}

class PassengerSettingData {
  const PassengerSettingData({required this.icon, required this.title});

  final String icon;
  final String title;

  factory PassengerSettingData.fromJson(Map<String, dynamic> json) =>
      PassengerSettingData(
        icon: (json['icon'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
      );
}

class PassengerPaymentMethodData {
  const PassengerPaymentMethodData({
    required this.provider,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.accentStart,
    required this.accentEnd,
  });

  final String provider;
  final String title;
  final String subtitle;
  final bool selected;
  final int accentStart;
  final int accentEnd;

  factory PassengerPaymentMethodData.fromJson(Map<String, dynamic> json) =>
      PassengerPaymentMethodData(
        provider: (json['provider'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        subtitle: (json['subtitle'] as String?) ?? '',
        selected: (json['selected'] as bool?) ?? false,
        accentStart: (json['accent_start'] as num?)?.toInt() ?? 0xFF3B82F6,
        accentEnd: (json['accent_end'] as num?)?.toInt() ?? 0xFF1D4ED8,
      );
}

class PassengerRecentTripData {
  const PassengerRecentTripData({
    required this.bookingUuid,
    required this.title,
    required this.time,
    required this.price,
    required this.rating,
    required this.driver,
  });

  final String bookingUuid;
  final String title;
  final String time;
  final String price;
  final String rating;
  final String driver;

  factory PassengerRecentTripData.fromJson(Map<String, dynamic> json) =>
      PassengerRecentTripData(
        bookingUuid: (json['booking_uuid'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        time: (json['time'] as String?) ?? '',
        price: (json['price'] as String?) ?? '',
        rating: (json['rating'] as String?) ?? '',
        driver: (json['driver'] as String?) ?? '',
      );
}

class PassengerProfileDashboard {
  const PassengerProfileDashboard({
    required this.summary,
    required this.metrics,
    required this.trust,
    required this.settings,
    required this.paymentMethods,
    required this.recentTrips,
    this.emergencyContacts = const [],
  });

  final PassengerProfileSummaryData summary;
  final List<PassengerProfileMetricData> metrics;
  final PassengerTrustData trust;
  final List<PassengerSettingData> settings;
  final List<PassengerPaymentMethodData> paymentMethods;
  final List<PassengerRecentTripData> recentTrips;
  final List<Map<String, dynamic>> emergencyContacts;

  factory PassengerProfileDashboard.fromJson(Map<String, dynamic> json) =>
      PassengerProfileDashboard(
        summary: PassengerProfileSummaryData.fromJson(
            json['summary'] is Map<String, dynamic>
                ? json['summary'] as Map<String, dynamic>
                : const {}),
        metrics: (json['metrics'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((m) => PassengerProfileMetricData.fromJson(m))
            .toList(),
        trust: PassengerTrustData.fromJson(
            json['trust'] is Map<String, dynamic>
                ? json['trust'] as Map<String, dynamic>
                : const {}),
        settings: (json['settings'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((s) => PassengerSettingData.fromJson(s))
            .toList(),
        paymentMethods: (json['payment_methods'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((p) => PassengerPaymentMethodData.fromJson(p))
            .toList(),
        recentTrips: (json['recent_trips'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((t) => PassengerRecentTripData.fromJson(t))
            .toList(),
        emergencyContacts: (json['emergency_contacts'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            [],
      );
}
