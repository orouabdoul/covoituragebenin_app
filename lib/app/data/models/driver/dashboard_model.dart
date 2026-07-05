class DashboardSummaryData {
  const DashboardSummaryData({
    required this.todayEarnings,
    required this.weekEarnings,
    required this.monthEarnings,
    required this.pendingCount,
    required this.totalCommission,
  });

  final int todayEarnings;
  final int weekEarnings;
  final int monthEarnings;
  final int pendingCount;
  final int totalCommission;

  factory DashboardSummaryData.fromJson(Map<String, dynamic> json) =>
      DashboardSummaryData(
        todayEarnings: (json['today_earnings'] as num?)?.toInt() ?? 0,
        weekEarnings: (json['week_earnings'] as num?)?.toInt() ?? 0,
        monthEarnings: (json['month_earnings'] as num?)?.toInt() ?? 0,
        pendingCount: (json['pending_count'] as num?)?.toInt() ?? 0,
        totalCommission: (json['total_commission'] as num?)?.toInt() ?? 0,
      );
}

class DashboardMetricData {
  const DashboardMetricData({
    required this.key,
    required this.value,
    required this.label,
    required this.progress,
  });

  final String key;
  final dynamic value;
  final String label;
  final double progress;

  factory DashboardMetricData.fromJson(Map<String, dynamic> json) =>
      DashboardMetricData(
        key: (json['key'] as String?) ?? '',
        value: json['value'],
        label: (json['label'] as String?) ?? '',
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      );
}

class DashboardPassengerData {
  const DashboardPassengerData({required this.name, required this.initials});

  final String name;
  final String initials;

  factory DashboardPassengerData.fromJson(Map<String, dynamic> json) =>
      DashboardPassengerData(
        name: (json['name'] as String?) ?? '',
        initials: (json['initials'] as String?) ?? '',
      );
}

class DashboardNextTripData {
  const DashboardNextTripData({
    required this.uuid,
    required this.departureCity,
    required this.departureNeighborhood,
    required this.arrivalCity,
    required this.arrivalNeighborhood,
    required this.departureTime,
    required this.status,
    required this.pricePerSeat,
    required this.availableSeats,
    required this.passengersCount,
    required this.passengers,
  });

  final String uuid;
  final String departureCity;
  final String departureNeighborhood;
  final String arrivalCity;
  final String arrivalNeighborhood;
  final String departureTime;
  final String status;
  final int pricePerSeat;
  final int availableSeats;
  final int passengersCount;
  final List<DashboardPassengerData> passengers;

  factory DashboardNextTripData.fromJson(Map<String, dynamic> json) =>
      DashboardNextTripData(
        uuid: (json['uuid'] as String?) ?? '',
        departureCity: (json['departure_city'] as String?) ?? '',
        departureNeighborhood: (json['departure_neighborhood'] as String?) ?? '',
        arrivalCity: (json['arrival_city'] as String?) ?? '',
        arrivalNeighborhood: (json['arrival_neighborhood'] as String?) ?? '',
        departureTime: (json['departure_time'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        pricePerSeat: (json['price_per_seat'] as num?)?.toInt() ?? 0,
        availableSeats: (json['available_seats'] as num?)?.toInt() ?? 0,
        passengersCount: (json['passengers_count'] as num?)?.toInt() ?? 0,
        passengers: (json['passengers'] as List?)
                ?.map((p) => DashboardPassengerData.fromJson(
                    p as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class DashboardRequestPassengerData {
  const DashboardRequestPassengerData({
    required this.name,
    required this.initials,
    required this.rating,
  });

  final String name;
  final String initials;
  final double rating;

  factory DashboardRequestPassengerData.fromJson(Map<String, dynamic> json) =>
      DashboardRequestPassengerData(
        name: (json['name'] as String?) ?? '',
        initials: (json['initials'] as String?) ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      );
}

class DashboardRequestTripData {
  const DashboardRequestTripData({
    required this.uuid,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
  });

  final String uuid;
  final String departureCity;
  final String arrivalCity;
  final String departureTime;

  factory DashboardRequestTripData.fromJson(Map<String, dynamic> json) =>
      DashboardRequestTripData(
        uuid: (json['uuid'] as String?) ?? '',
        departureCity: (json['departure_city'] as String?) ?? '',
        arrivalCity: (json['arrival_city'] as String?) ?? '',
        departureTime: (json['departure_time'] as String?) ?? '',
      );
}

class DashboardRequestData {
  const DashboardRequestData({
    required this.uuid,
    required this.status,
    required this.seatsBooked,
    required this.createdAt,
    required this.passenger,
    required this.trip,
  });

  final String uuid;
  final String status;
  final int seatsBooked;
  final String createdAt;
  final DashboardRequestPassengerData passenger;
  final DashboardRequestTripData trip;

  factory DashboardRequestData.fromJson(Map<String, dynamic> json) =>
      DashboardRequestData(
        uuid: (json['uuid'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        seatsBooked: (json['seats_booked'] as num?)?.toInt() ?? 1,
        createdAt: (json['created_at'] as String?) ?? '',
        passenger: DashboardRequestPassengerData.fromJson(
            (json['passenger'] as Map<String, dynamic>?) ?? {}),
        trip: DashboardRequestTripData.fromJson(
            (json['trip'] as Map<String, dynamic>?) ?? {}),
      );
}

class DashboardWalletData {
  const DashboardWalletData({
    required this.availableBalance,
    required this.blockedAmount,
  });

  final int availableBalance;
  final int blockedAmount;

  factory DashboardWalletData.fromJson(Map<String, dynamic> json) =>
      DashboardWalletData(
        availableBalance: (json['available_balance'] as num?)?.toInt() ?? 0,
        blockedAmount: (json['blocked_amount'] as num?)?.toInt() ?? 0,
      );
}

class DashboardBadgeData {
  const DashboardBadgeData({required this.key, required this.label});

  final String key;
  final String label;

  factory DashboardBadgeData.fromJson(Map<String, dynamic> json) =>
      DashboardBadgeData(
        key: (json['key'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
      );
}

class DashboardLevelData {
  const DashboardLevelData({
    required this.currentLevel,
    required this.progress,
    required this.nextLevel,
    required this.tripsToNext,
    required this.badges,
  });

  final String currentLevel;
  final double progress;
  final String nextLevel;
  final int tripsToNext;
  final List<DashboardBadgeData> badges;

  factory DashboardLevelData.fromJson(Map<String, dynamic> json) =>
      DashboardLevelData(
        currentLevel: (json['current_level'] as String?) ?? '',
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        nextLevel: (json['next_level'] as String?) ?? '',
        tripsToNext: (json['trips_to_next'] as num?)?.toInt() ?? 0,
        badges: (json['badges'] as List?)
                ?.map((b) =>
                    DashboardBadgeData.fromJson(b as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class DashboardModel {
  const DashboardModel({
    required this.summary,
    required this.metrics,
    this.nextTrip,
    required this.quickRequests,
    required this.recentRequests,
    required this.wallet,
    required this.level,
    required this.isOnline,
    required this.availabilityMode,
  });

  final DashboardSummaryData summary;
  final List<DashboardMetricData> metrics;
  final DashboardNextTripData? nextTrip;
  final List<DashboardRequestData> quickRequests;
  final List<DashboardRequestData> recentRequests;
  final DashboardWalletData wallet;
  final DashboardLevelData level;
  final bool isOnline;
  final String availabilityMode;

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        summary: DashboardSummaryData.fromJson(
            (json['summary'] as Map<String, dynamic>?) ?? {}),
        metrics: (json['metrics'] as List?)
                ?.map((m) =>
                    DashboardMetricData.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
        nextTrip: json['next_trip'] != null
            ? DashboardNextTripData.fromJson(
                json['next_trip'] as Map<String, dynamic>)
            : null,
        quickRequests: (json['quick_requests'] as List?)
                ?.map((r) =>
                    DashboardRequestData.fromJson(r as Map<String, dynamic>))
                .toList() ??
            [],
        recentRequests: (json['recent_requests'] as List?)
                ?.map((r) =>
                    DashboardRequestData.fromJson(r as Map<String, dynamic>))
                .toList() ??
            [],
        wallet: DashboardWalletData.fromJson(
            (json['wallet'] as Map<String, dynamic>?) ?? {}),
        level: DashboardLevelData.fromJson(
            (json['level'] as Map<String, dynamic>?) ?? {}),
        isOnline: (json['is_online'] as bool?) ?? false,
        availabilityMode: (json['availability_mode'] as String?) ?? 'normal',
      );
}
