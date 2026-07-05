class TripDetailRouteData {
  const TripDetailRouteData({
    required this.origin,
    required this.originPoint,
    required this.destination,
    required this.destinationPoint,
    required this.departureTime,
    required this.departureDate,
    required this.departureDateLabel,
  });

  final String origin;
  final String originPoint;
  final String destination;
  final String destinationPoint;
  final String departureTime;
  final String departureDate;
  final String departureDateLabel;

  factory TripDetailRouteData.fromJson(Map<String, dynamic> json) =>
      TripDetailRouteData(
        origin: (json['origin'] as String?) ?? '',
        originPoint: (json['origin_point'] as String?) ?? '',
        destination: (json['destination'] as String?) ?? '',
        destinationPoint: (json['destination_point'] as String?) ?? '',
        departureTime: (json['departure_time'] as String?) ?? '',
        departureDate: (json['departure_date'] as String?) ?? '',
        departureDateLabel: (json['departure_date_label'] as String?) ?? '',
      );
}

class TripDetailVehicleData {
  const TripDetailVehicleData({
    required this.label,
    required this.make,
    required this.model,
    required this.plate,
  });

  final String label;
  final String make;
  final String model;
  final String plate;

  factory TripDetailVehicleData.fromJson(Map<String, dynamic> json) =>
      TripDetailVehicleData(
        label: (json['label'] as String?) ?? '',
        make: (json['make'] as String?) ?? '',
        model: (json['model'] as String?) ?? '',
        plate: (json['plate'] as String?) ?? '',
      );
}

class TripDetailSeatsData {
  const TripDetailSeatsData({
    required this.total,
    required this.booked,
    required this.available,
    required this.pricePerSeat,
    required this.priceLabel,
  });

  final int total;
  final int booked;
  final int available;
  final int pricePerSeat;
  final String priceLabel;

  factory TripDetailSeatsData.fromJson(Map<String, dynamic> json) =>
      TripDetailSeatsData(
        total: (json['total'] as num?)?.toInt() ?? 0,
        booked: (json['booked'] as num?)?.toInt() ?? 0,
        available: (json['available'] as num?)?.toInt() ?? 0,
        pricePerSeat: (json['price_per_seat'] as num?)?.toInt() ?? 0,
        priceLabel: (json['price_label'] as String?) ?? '',
      );
}

class TripDetailPassengerData {
  const TripDetailPassengerData({
    required this.bookingUuid,
    required this.fullName,
    required this.initials,
    required this.phone,
    required this.seatsBooked,
    required this.amount,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.rating,
    required this.tripsCount,
    required this.isVerified,
  });

  final String bookingUuid;
  final String fullName;
  final String initials;
  final String phone;
  final int seatsBooked;
  final int amount;
  final String paymentStatus;
  final String bookingStatus;
  final double rating;
  final int tripsCount;
  final bool isVerified;

  factory TripDetailPassengerData.fromJson(Map<String, dynamic> json) =>
      TripDetailPassengerData(
        bookingUuid: (json['booking_uuid'] as String?) ?? '',
        fullName: (json['full_name'] as String?) ?? '',
        initials: (json['initials'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
        seatsBooked: (json['seats_booked'] as num?)?.toInt() ?? 1,
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        paymentStatus: (json['payment_status'] as String?) ?? 'pending',
        bookingStatus: (json['booking_status'] as String?) ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        tripsCount: (json['trips_count'] as num?)?.toInt() ?? 0,
        isVerified: (json['is_verified'] as bool?) ?? false,
      );
}

class TripDetailFinancesData {
  const TripDetailFinancesData({
    required this.totalRevenue,
    required this.commissionRate,
    required this.commission,
    required this.netRevenue,
  });

  final int totalRevenue;
  final int commissionRate;
  final int commission;
  final int netRevenue;

  factory TripDetailFinancesData.fromJson(Map<String, dynamic> json) =>
      TripDetailFinancesData(
        totalRevenue: (json['total_revenue'] as num?)?.toInt() ?? 0,
        commissionRate: (json['commission_rate'] as num?)?.toInt() ?? 10,
        commission: (json['commission'] as num?)?.toInt() ?? 0,
        netRevenue: (json['net_revenue'] as num?)?.toInt() ?? 0,
      );
}

class TripDetailStatsData {
  const TripDetailStatsData({
    required this.distanceKm,
    required this.durationMinutes,
    required this.durationLabel,
    required this.availableSeats,
  });

  final double distanceKm;
  final int durationMinutes;
  final String durationLabel;
  final int availableSeats;

  factory TripDetailStatsData.fromJson(Map<String, dynamic> json) =>
      TripDetailStatsData(
        distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
        durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
        durationLabel: (json['duration_label'] as String?) ?? '',
        availableSeats: (json['available_seats'] as num?)?.toInt() ?? 0,
      );
}

class TripDetailActionsData {
  const TripDetailActionsData({
    required this.canStart,
    required this.canEdit,
    required this.canCancel,
  });

  final bool canStart;
  final bool canEdit;
  final bool canCancel;

  factory TripDetailActionsData.fromJson(Map<String, dynamic> json) =>
      TripDetailActionsData(
        canStart: (json['can_start'] as bool?) ?? false,
        canEdit: (json['can_edit'] as bool?) ?? false,
        canCancel: (json['can_cancel'] as bool?) ?? false,
      );
}

List<TripDetailPassengerData> _parsePassengers(dynamic raw) {
  List<dynamic> list;
  if (raw is List) {
    list = raw;
  } else if (raw is Map) {
    list = (raw['data'] ?? raw['items'] ?? raw['passengers'] ?? []) as List? ?? [];
  } else {
    return [];
  }
  return list
      .map((p) => TripDetailPassengerData.fromJson(p as Map<String, dynamic>))
      .toList();
}

class TripDetailModel {
  const TripDetailModel({
    required this.uuid,
    required this.status,
    required this.statusLabel,
    required this.publishedAgo,
    required this.route,
    this.vehicle,
    required this.seats,
    required this.passengers,
    required this.finances,
    required this.stats,
    required this.actions,
  });

  final String uuid;
  final String status;
  final String statusLabel;
  final String publishedAgo;
  final TripDetailRouteData route;
  final TripDetailVehicleData? vehicle;
  final TripDetailSeatsData seats;
  final List<TripDetailPassengerData> passengers;
  final TripDetailFinancesData finances;
  final TripDetailStatsData stats;
  final TripDetailActionsData actions;

  factory TripDetailModel.fromJson(Map<String, dynamic> json) => TripDetailModel(
        uuid: (json['uuid'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        statusLabel: (json['status_label'] as String?) ?? '',
        publishedAgo: (json['published_ago'] as String?) ?? '',
        route: TripDetailRouteData.fromJson(
            (json['route'] as Map<String, dynamic>?) ?? {}),
        vehicle: json['vehicle'] != null
            ? TripDetailVehicleData.fromJson(
                json['vehicle'] as Map<String, dynamic>)
            : null,
        seats: TripDetailSeatsData.fromJson(
            (json['seats'] as Map<String, dynamic>?) ?? {}),
        passengers: _parsePassengers(json['passengers']),
        finances: TripDetailFinancesData.fromJson(
            (json['finances'] as Map<String, dynamic>?) ?? {}),
        stats: TripDetailStatsData.fromJson(
            (json['stats'] as Map<String, dynamic>?) ?? {}),
        actions: TripDetailActionsData.fromJson(
            (json['actions'] as Map<String, dynamic>?) ?? {}),
      );
}
