class TripDetailRouteData {
  const TripDetailRouteData({
    required this.origin,
    required this.originPoint,
    this.departureArrondissement = '',
    this.departureNeighborhood = '',
    required this.destination,
    required this.destinationPoint,
    this.arrivalArrondissement = '',
    this.arrivalNeighborhood = '',
    required this.departureTime,
    required this.departureDate,
    required this.departureDateLabel,
    this.departureAt = '',
  });

  final String origin;
  final String originPoint;
  final String departureArrondissement;
  final String departureNeighborhood;
  final String destination;
  final String destinationPoint;
  final String arrivalArrondissement;
  final String arrivalNeighborhood;
  final String departureTime;
  final String departureDate;
  final String departureDateLabel;
  // ISO datetime pour la règle des 5 min avant départ
  final String departureAt;

  factory TripDetailRouteData.fromJson(Map<String, dynamic> json) {
    final depDate = (json['departure_date'] as String?) ?? '';
    final depTime = (json['departure_time'] as String?) ?? '';
    // Priorité à departure_at ISO, sinon construit depuis date+heure (DD/MM/YYYY + HH:mm)
    String departureAt = (json['departure_at'] as String?) ?? '';
    if (departureAt.isEmpty && depDate.isNotEmpty && depTime.isNotEmpty) {
      departureAt = _buildIso(depDate, depTime);
    }
    return TripDetailRouteData(
      origin: (json['origin'] as String?) ?? '',
      originPoint: (json['origin_point'] as String?) ?? '',
      departureArrondissement: (json['departure_arrondissement'] as String?) ?? '',
      departureNeighborhood: (json['departure_neighborhood'] as String?) ?? '',
      destination: (json['destination'] as String?) ?? '',
      destinationPoint: (json['destination_point'] as String?) ?? '',
      arrivalArrondissement: (json['arrival_arrondissement'] as String?) ?? '',
      arrivalNeighborhood: (json['arrival_neighborhood'] as String?) ?? '',
      departureTime: depTime,
      departureDate: depDate,
      departureDateLabel: (json['departure_date_label'] as String?) ?? '',
      departureAt: departureAt,
    );
  }

  // "15/08/2025" + "08:00" → "2025-08-15T08:00:00"
  static String _buildIso(String date, String time) {
    try {
      final p = date.split('/');
      if (p.length != 3) return '';
      return '${p[2]}-${p[1].padLeft(2, '0')}-${p[0].padLeft(2, '0')}T$time:00';
    } catch (_) {
      return '';
    }
  }
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
        // API returns total_seats / booked_seats / available_seats inside passengers object
        total: (json['total_seats'] ?? json['total'] as num?)?.toInt() ?? 0,
        booked: (json['booked_seats'] ?? json['booked'] as num?)?.toInt() ?? 0,
        available: (json['available_seats'] ?? json['available'] as num?)?.toInt() ?? 0,
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
        // API returns "name" and "avatar_initial"
        fullName: (json['full_name'] ?? json['name'] as String?) ?? '',
        initials: (json['initials'] ?? json['avatar_initial'] as String?) ?? '',
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
        // API returns commission_amount, not commission
        commission: (json['commission_amount'] ?? json['commission'] as num?)?.toInt() ?? 0,
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
    // API nests the passenger list under passengers.list
    list = (raw['list'] ?? raw['data'] ?? raw['items'] ?? raw['passengers'] ?? []) as List? ?? [];
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

  factory TripDetailModel.fromJson(Map<String, dynamic> json) {
    final passengersObj = (json['passengers'] as Map<String, dynamic>?) ?? {};
    final financesObj = (json['finances'] as Map<String, dynamic>?) ?? {};
    // Seats info lives inside passengers object; inject price_per_seat from finances
    final seatsJson = {
      ...passengersObj,
      if (financesObj['price_per_seat'] != null)
        'price_per_seat': financesObj['price_per_seat'],
    };
    return TripDetailModel(
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
      // Seats are inside the passengers object in the API
      seats: TripDetailSeatsData.fromJson(seatsJson),
      passengers: _parsePassengers(passengersObj),
      finances: TripDetailFinancesData.fromJson(financesObj),
      stats: TripDetailStatsData.fromJson(
          (json['stats'] as Map<String, dynamic>?) ?? {}),
      // can_start / can_edit / can_cancel are at the root level, not nested in actions
      actions: TripDetailActionsData.fromJson(json),
    );
  }
}
