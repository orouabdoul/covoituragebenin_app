class PassengerUpcomingTripData {
  const PassengerUpcomingTripData({
    required this.bookingUuid,
    required this.tripUuid,
    required this.status,
    required this.origin,
    required this.destination,
    this.etaMinutes,
    required this.tripProgress,
    required this.departureTime,
    required this.driverName,
    required this.driverInitials,
    required this.driverRating,
    required this.driverVehicle,
    required this.driverLevel,
    required this.driverTrips,
    required this.driverLevelProgress,
    required this.driverBadges,
  });

  final String bookingUuid;
  final String tripUuid;
  final String status;
  final String origin;
  final String destination;
  final int? etaMinutes;
  final double tripProgress;
  final String departureTime;
  final String driverName;
  final String driverInitials;
  final double driverRating;
  final String driverVehicle;
  final String driverLevel;
  final int driverTrips;
  final double driverLevelProgress;
  final List<String> driverBadges;

  factory PassengerUpcomingTripData.fromJson(Map<String, dynamic> json) =>
      PassengerUpcomingTripData(
        bookingUuid: (json['booking_uuid'] as String?) ?? '',
        tripUuid: (json['trip_uuid'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        origin: (json['origin'] as String?) ?? '',
        destination: (json['destination'] as String?) ?? '',
        etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
        tripProgress: (json['trip_progress'] as num?)?.toDouble() ?? 0.0,
        departureTime: (json['departure_time'] as String?) ?? '',
        driverName: (json['driver_name'] as String?) ?? '',
        driverInitials: (json['driver_initials'] as String?) ?? '',
        driverRating: (json['driver_rating'] as num?)?.toDouble() ?? 0.0,
        driverVehicle: (json['driver_vehicle'] as String?) ?? '',
        driverLevel: (json['driver_level'] as String?) ?? '',
        driverTrips: (json['driver_trips'] as num?)?.toInt() ?? 0,
        driverLevelProgress:
            (json['driver_level_progress'] as num?)?.toDouble() ?? 0.0,
        driverBadges: (json['driver_badges'] as List?)
                ?.map((b) => b as String)
                .toList() ??
            [],
      );
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
        upcomingTrip: json['upcoming_trip'] != null
            ? PassengerUpcomingTripData.fromJson(
                json['upcoming_trip'] as Map<String, dynamic>)
            : null,
        heroMetrics: (json['hero_metrics'] as List?)
                ?.map((m) =>
                    PassengerMetricData.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
        popularRoutes: (json['popular_routes'] as List?)
                ?.map((r) =>
                    PassengerRouteData.fromJson(r as Map<String, dynamic>))
                .toList() ??
            [],
        availableRides: (json['available_rides'] as List?)
                ?.map((r) =>
                    PassengerRideData.fromJson(r as Map<String, dynamic>))
                .toList() ??
            [],
        recommendedDrivers: (json['recommended_drivers'] as List?)
                ?.map((d) =>
                    PassengerDriverData.fromJson(d as Map<String, dynamic>))
                .toList() ??
            [],
        specialOffers: (json['special_offers'] as List?)
                ?.map((o) =>
                    PassengerOfferData.fromJson(o as Map<String, dynamic>))
                .toList() ??
            [],
        recentActivities: (json['recent_activities'] as List?)
                ?.map((a) =>
                    PassengerActivityData.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
