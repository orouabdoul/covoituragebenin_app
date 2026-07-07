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
        total: j['total'] as int? ?? 0,
        accepted: j['accepted'] as int? ?? 0,
        completed: j['completed'] as int? ?? 0,
        cancelled: j['cancelled'] as int? ?? 0,
        rejected: j['rejected'] as int? ?? 0,
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
        totalFcfa: j['total_fcfa'] as int? ?? 0,
        thisMonthFcfa: j['this_month_fcfa'] as int? ?? 0,
      );
}

class PassengerTopDriver {
  const PassengerTopDriver({
    required this.name,
    required this.initials,
    required this.tripsCount,
    required this.rating,
  });

  final String name;
  final String initials;
  final int tripsCount;
  final String rating;

  factory PassengerTopDriver.fromJson(Map<String, dynamic> j) =>
      PassengerTopDriver(
        name: j['name'] as String? ?? '',
        initials: j['initials'] as String? ?? '',
        tripsCount: j['trips_count'] as int? ?? 0,
        rating: j['rating'] as String? ?? '',
      );
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
            j['bookings'] as Map<String, dynamic>),
        spending: PassengerStatsSpending.fromJson(
            j['spending'] as Map<String, dynamic>),
        topDrivers: (j['top_drivers'] as List<dynamic>? ?? [])
            .map((e) => PassengerTopDriver.fromJson(e as Map<String, dynamic>))
            .toList(),
        memberSince: j['member_since'] as String? ?? '',
      );
}
