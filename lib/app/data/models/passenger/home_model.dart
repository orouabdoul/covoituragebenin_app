class PassengerUpcomingTripData {
  const PassengerUpcomingTripData({
    required this.bookingUuid,
    required this.tripUuid,
    required this.status,
    required this.origin,
    required this.destination,
    this.originPoint = '',
    this.destinationPoint = '',
    this.pickupCity = '',
    this.dropoffCity = '',
    this.pickupNote = '',
    this.dropoffNote = '',
    this.proratedPrice = 0,
    this.etaMinutes,
    required this.tripProgress,
    required this.departureTime,
    required this.driverName,
    required this.driverInitials,
    required this.driverRating,
    required this.driverVehicle,
    this.vehiclePlate = '',
    required this.driverLevel,
    required this.driverTrips,
    required this.driverLevelProgress,
    required this.driverBadges,
    this.seatsBooked = 1,
    this.completedStops = 0,
    this.totalStops = 0,
    this.driverPhone = '',
  });

  final String bookingUuid;
  final String tripUuid;
  final String status;
  final String origin;
  final String destination;
  final String originPoint;
  final String destinationPoint;
  final String pickupCity;
  final String dropoffCity;
  final String pickupNote;
  final String dropoffNote;
  final int proratedPrice;
  final int? etaMinutes;
  final double tripProgress;
  final String departureTime;
  final String driverName;
  final String driverInitials;
  final double driverRating;
  final String driverVehicle;
  final String vehiclePlate;
  final String driverLevel;
  final int driverTrips;
  final double driverLevelProgress;
  final List<String> driverBadges;
  final int seatsBooked;
  final int completedStops;
  final int totalStops;
  final String driverPhone;

  factory PassengerUpcomingTripData.fromJson(Map<String, dynamic> json) {
    final origin = (json['origin'] as String?) ?? '';
    final destination = (json['destination'] as String?) ?? '';
    final originPoint = (json['origin_point'] as String?)?.isNotEmpty == true
        ? json['origin_point'] as String
        : (json['pickup_point'] as String?)?.isNotEmpty == true
            ? json['pickup_point'] as String
            : origin;
    final destinationPoint =
        (json['destination_point'] as String?)?.isNotEmpty == true
            ? json['destination_point'] as String
            : (json['dropoff_point'] as String?)?.isNotEmpty == true
                ? json['dropoff_point'] as String
                : destination;
    return PassengerUpcomingTripData(
      bookingUuid: (json['booking_uuid'] as String?) ?? '',
      tripUuid: (json['trip_uuid'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      origin: origin,
      destination: destination,
      originPoint: originPoint,
      destinationPoint: destinationPoint,
      pickupCity: (json['pickup_city'] as String?)?.isNotEmpty == true
          ? json['pickup_city'] as String
          : originPoint,
      dropoffCity: (json['dropoff_city'] as String?)?.isNotEmpty == true
          ? json['dropoff_city'] as String
          : destinationPoint,
      pickupNote: (json['pickup_note'] as String?) ?? '',
      dropoffNote: (json['dropoff_note'] as String?) ?? '',
      proratedPrice: (json['calculated_price'] as num?)?.toInt() ??
          (json['amount_paid'] as num?)?.toInt() ?? 0,
      etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
      tripProgress: (json['trip_progress'] as num?)?.toDouble() ?? 0.0,
      departureTime: (json['departure_time'] as String?) ?? '',
      driverName: (json['driver_name'] as String?) ?? '',
      driverInitials: (json['driver_initials'] as String?) ?? '',
      driverRating: (json['driver_rating'] as num?)?.toDouble() ?? 0.0,
      driverVehicle: (json['driver_vehicle'] as String?) ?? '',
      vehiclePlate: (json['vehicle_plate'] as String?) ?? '',
      driverLevel: (json['driver_level'] as String?) ?? '',
      driverTrips: (json['driver_trips'] as num?)?.toInt() ?? 0,
      driverLevelProgress:
          (json['driver_level_progress'] as num?)?.toDouble() ?? 0.0,
      driverBadges: (json['driver_badges'] as List?)
              ?.map((b) => b.toString())
              .toList() ??
          [],
      seatsBooked: (json['seats_booked'] as num?)?.toInt() ?? 1,
      completedStops: (json['completed_stops'] as num?)?.toInt() ?? 0,
      totalStops: (json['total_stops'] as num?)?.toInt() ?? 0,
      driverPhone: (json['driver_phone'] as String?) ?? '',
    );
  }
}

class PassengerMetricData {
  const PassengerMetricData({required this.label, required this.value});

  final String label;
  final String value;

  factory PassengerMetricData.fromJson(Map<String, dynamic> json) =>
      PassengerMetricData(
        label: (json['label'] as String?) ?? '',
        value: (json['value'] as String?) ?? '',
      );
}

class PassengerRouteData {
  const PassengerRouteData({
    required this.label,
    required this.departureCity,
    required this.arrivalCity,
    required this.count,
  });

  final String label;
  final String departureCity;
  final String arrivalCity;
  final int count;

  factory PassengerRouteData.fromJson(Map<String, dynamic> json) =>
      PassengerRouteData(
        label: (json['label'] as String?) ?? '',
        departureCity: (json['departure_city'] as String?) ?? '',
        arrivalCity: (json['arrival_city'] as String?) ?? '',
        count: (json['count'] as num?)?.toInt() ?? 0,
      );
}

class PassengerRideData {
  const PassengerRideData({
    required this.uuid,
    required this.from,
    required this.to,
    required this.schedule,
    required this.price,
    required this.priceRaw,
    required this.seatsLeft,
    required this.driverName,
    required this.driverVehicle,
    this.status = '',
    this.departureTimeRaw = '',
  });

  final String uuid;
  final String from;
  final String to;
  final String schedule;
  final String price;
  final int priceRaw;
  final String seatsLeft;
  final String driverName;
  final String driverVehicle;
  final String status;
  final String departureTimeRaw;

  factory PassengerRideData.fromJson(Map<String, dynamic> json) =>
      PassengerRideData(
        uuid: (json['uuid'] as String?) ?? '',
        from: (json['from'] as String?) ?? '',
        to: (json['to'] as String?) ?? '',
        schedule: (json['schedule'] as String?) ?? '',
        price: (json['price'] as String?) ?? '',
        priceRaw: (json['price_raw'] as num?)?.toInt() ?? 0,
        seatsLeft: (json['seats_left'] as String?) ?? '',
        driverName: (json['driver_name'] as String?) ?? '',
        driverVehicle: (json['driver_vehicle'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        // Tente plusieurs noms de champ possibles pour la date de départ
        departureTimeRaw: (json['departure_time'] as String?) ??
            (json['departure_at'] as String?) ??
            (json['scheduled_at'] as String?) ??
            (json['departs_at'] as String?) ??
            '',
      );
}

class PassengerDriverData {
  const PassengerDriverData({
    required this.uuid,
    required this.name,
    required this.initials,
    required this.vehicle,
    required this.rating,
    required this.tripsCount,
  });

  final String uuid;
  final String name;
  final String initials;
  final String vehicle;
  final String rating;
  final String tripsCount;

  factory PassengerDriverData.fromJson(Map<String, dynamic> json) =>
      PassengerDriverData(
        uuid: (json['uuid'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        initials: (json['initials'] as String?) ?? '',
        vehicle: (json['vehicle'] as String?) ?? '',
        rating: (json['rating'] as String?) ?? '',
        tripsCount: (json['trips_count'] as String?) ?? '',
      );
}

class PassengerOfferData {
  const PassengerOfferData({
    required this.key,
    required this.title,
    required this.subtitle,
  });

  final String key;
  final String title;
  final String subtitle;

  factory PassengerOfferData.fromJson(Map<String, dynamic> json) =>
      PassengerOfferData(
        key: (json['key'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        subtitle: (json['subtitle'] as String?) ?? '',
      );
}

class PassengerActivityData {
  const PassengerActivityData({
    required this.bookingUuid,
    required this.route,
    required this.time,
    required this.status,
    required this.price,
  });

  final String bookingUuid;
  final String route;
  final String time;
  final String status;
  final int price;

  factory PassengerActivityData.fromJson(Map<String, dynamic> json) =>
      PassengerActivityData(
        bookingUuid: (json['booking_uuid'] as String?) ?? '',
        route: (json['route'] as String?) ?? '',
        time: (json['time'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
      );
}

class PassengerHomeDashboard {
  const PassengerHomeDashboard({
    required this.greeting,
    this.upcomingTrip,
    required this.heroMetrics,
    required this.popularRoutes,
    required this.availableRides,
    required this.recommendedDrivers,
    required this.specialOffers,
    required this.recentActivities,
  });

  final String greeting;
  final PassengerUpcomingTripData? upcomingTrip;
  final List<PassengerMetricData> heroMetrics;
  final List<PassengerRouteData> popularRoutes;
  final List<PassengerRideData> availableRides;
  final List<PassengerDriverData> recommendedDrivers;
  final List<PassengerOfferData> specialOffers;
  final List<PassengerActivityData> recentActivities;

  factory PassengerHomeDashboard.fromJson(Map<String, dynamic> json) =>
      PassengerHomeDashboard(
        greeting: (json['greeting'] as String?) ?? '',
        upcomingTrip: json['upcoming_trip'] is Map<String, dynamic>
            ? PassengerUpcomingTripData.fromJson(
                json['upcoming_trip'] as Map<String, dynamic>)
            : null,
        heroMetrics: (json['hero_metrics'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((m) => PassengerMetricData.fromJson(m))
            .toList(),
        popularRoutes: (json['popular_routes'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((r) => PassengerRouteData.fromJson(r))
            .toList(),
        availableRides: (json['available_rides'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((r) => PassengerRideData.fromJson(r))
            .toList(),
        recommendedDrivers: (json['recommended_drivers'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((d) => PassengerDriverData.fromJson(d))
            .toList(),
        specialOffers: (json['special_offers'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((o) => PassengerOfferData.fromJson(o))
            .toList(),
        recentActivities: (json['recent_activities'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((a) => PassengerActivityData.fromJson(a))
            .toList(),
      );
}
