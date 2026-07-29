class PassengerStatsBookings {
  const PassengerStatsBookings({
    required this.total,
    required this.accepted,
    required this.completed,
    required this.cancelled,
    required this.rejected,
  });

  final int total;
  final int accepted;
  final int completed;
  final int cancelled;
  final int rejected;

  factory PassengerStatsBookings.fromJson(Map<String, dynamic> j) =>
      PassengerStatsBookings(
        total: (j['total'] as num?)?.toInt() ?? 0,
        accepted: (j['accepted'] as num?)?.toInt() ?? 0,
        completed: (j['completed'] as num?)?.toInt() ?? 0,
        cancelled: (j['cancelled'] as num?)?.toInt() ?? 0,
        rejected: (j['rejected'] as num?)?.toInt() ?? 0,
      );
}

class PassengerStatsSpending {
  const PassengerStatsSpending({
    required this.totalFcfa,
    required this.thisMonthFcfa,
  });

  final int totalFcfa;
  final int thisMonthFcfa;

  factory PassengerStatsSpending.fromJson(Map<String, dynamic> j) =>
      PassengerStatsSpending(
        totalFcfa: (j['total_fcfa'] as num?)?.toInt() ?? 0,
        thisMonthFcfa: (j['this_month_fcfa'] as num?)?.toInt() ?? 0,
      );
}

class PassengerTopDriver {
  const PassengerTopDriver({
    required this.driverUuid,
    required this.name,
    required this.initials,
    required this.tripsCount,
    required this.totalSpent,
  });

  final String driverUuid;
  final String name;
  final String initials;
  final int tripsCount;
  final int totalSpent;

  factory PassengerTopDriver.fromJson(Map<String, dynamic> j) {
    final rawName = (j['driver_name'] ?? '').toString();
    final initials = rawName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return PassengerTopDriver(
      driverUuid: (j['driver_uuid'] ?? '').toString(),
      name: rawName,
      initials: initials,
      tripsCount: (j['trips_count'] as num?)?.toInt() ?? 0,
      totalSpent: (j['total_spent'] as num?)?.toInt() ?? 0,
    );
  }
}

class PassengerStatsModel {
  const PassengerStatsModel({
    required this.bookings,
    required this.spending,
    required this.topDrivers,
    required this.memberSince,
  });

  final PassengerStatsBookings bookings;
  final PassengerStatsSpending spending;
  final List<PassengerTopDriver> topDrivers;
  final String memberSince;

  factory PassengerStatsModel.fromJson(Map<String, dynamic> j) =>
      PassengerStatsModel(
        bookings: PassengerStatsBookings.fromJson(
            (j['bookings'] as Map<String, dynamic>?) ?? {}),
        spending: PassengerStatsSpending.fromJson(
            (j['spending'] as Map<String, dynamic>?) ?? {}),
        topDrivers: (j['top_drivers'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((e) => PassengerTopDriver.fromJson(e))
            .toList(),
        memberSince: (j['member_since'] ?? '').toString(),
      );
}
