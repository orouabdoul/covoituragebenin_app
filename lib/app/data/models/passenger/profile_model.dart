class PassengerProfileSummaryData {
  const PassengerProfileSummaryData({
    required this.avatarUrl,
    required this.name,
    required this.phone,
    required this.isVerified,
  });

  final String avatarUrl;
  final String name;
  final String phone;
  final bool isVerified;

  factory PassengerProfileSummaryData.fromJson(Map<String, dynamic> json) =>
      PassengerProfileSummaryData(
        avatarUrl: (json['avatar_url'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
        isVerified: (json['is_verified'] as bool?) ?? false,
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
        items: (json['items'] as List?)
                ?.map((i) =>
                    PassengerTrustItemData.fromJson(i as Map<String, dynamic>))
                .toList() ??
            [],
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
  });

  final PassengerProfileSummaryData summary;
  final List<PassengerProfileMetricData> metrics;
  final PassengerTrustData trust;
  final List<PassengerSettingData> settings;
  final List<PassengerPaymentMethodData> paymentMethods;
  final List<PassengerRecentTripData> recentTrips;

  factory PassengerProfileDashboard.fromJson(Map<String, dynamic> json) =>
      PassengerProfileDashboard(
        summary: PassengerProfileSummaryData.fromJson(
            (json['summary'] as Map<String, dynamic>?) ?? {}),
        metrics: (json['metrics'] as List?)
                ?.map((m) => PassengerProfileMetricData.fromJson(
                    m as Map<String, dynamic>))
                .toList() ??
            [],
        trust: PassengerTrustData.fromJson(
            (json['trust'] as Map<String, dynamic>?) ?? {}),
        settings: (json['settings'] as List?)
                ?.map((s) =>
                    PassengerSettingData.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        paymentMethods: (json['payment_methods'] as List?)
                ?.map((p) => PassengerPaymentMethodData.fromJson(
                    p as Map<String, dynamic>))
                .toList() ??
            [],
        recentTrips: (json['recent_trips'] as List?)
                ?.map((t) => PassengerRecentTripData.fromJson(
                    t as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
