// Modèle pour GET /api/trips/{uuid}/tracking

class TripTrackingModel {
  const TripTrackingModel({
    required this.uuid,
    required this.status,
    this.currentLat,
    this.currentLng,
    this.currentSpeed,
    this.locationUpdatedAt,
    required this.departureCity,
    required this.arrivalCity,
    this.departureLat,
    this.departureLng,
    this.arrivalLat,
    this.arrivalLng,
    required this.driverName,
    required this.driverPhone,
  });

  final String uuid;
  final String status;
  final double? currentLat;
  final double? currentLng;
  final double? currentSpeed;
  final DateTime? locationUpdatedAt;
  final String departureCity;
  final String arrivalCity;
  final double? departureLat;
  final double? departureLng;
  final double? arrivalLat;
  final double? arrivalLng;
  final String driverName;
  final String driverPhone;

  // Priorité GPS : actuel → départ → arrivée
  double? get effectiveLat => currentLat ?? departureLat ?? arrivalLat;
  double? get effectiveLng => currentLng ?? departureLng ?? arrivalLng;

  bool get hasGps => currentLat != null && currentLng != null;

  bool get gpsStale {
    final updated = locationUpdatedAt;
    if (updated == null) return false;
    return DateTime.now().difference(updated).inMinutes >= 2;
  }

  factory TripTrackingModel.fromJson(Map<String, dynamic> j) {
    final driver = j['driver'] as Map<String, dynamic>? ?? {};
    return TripTrackingModel(
      uuid: j['uuid']?.toString() ?? '',
      status: j['status']?.toString() ?? 'pending',
      currentLat: (j['current_latitude'] as num?)?.toDouble(),
      currentLng: (j['current_longitude'] as num?)?.toDouble(),
      currentSpeed: (j['current_speed'] as num?)?.toDouble(),
      locationUpdatedAt: _parseDate(j['location_updated_at']),
      departureCity: j['departure_city']?.toString() ?? '',
      arrivalCity: j['arrival_city']?.toString() ?? '',
      departureLat: (j['departure_latitude'] as num?)?.toDouble(),
      departureLng: (j['departure_longitude'] as num?)?.toDouble(),
      arrivalLat: (j['arrival_latitude'] as num?)?.toDouble(),
      arrivalLng: (j['arrival_longitude'] as num?)?.toDouble(),
      driverName: driver['name']?.toString() ?? '',
      driverPhone: driver['phone']?.toString() ?? '',
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString()) ??
        DateTime.tryParse(raw.toString().replaceFirst(' ', 'T'));
  }
}

// ── Modèle réservation active passager ──────────────────────────────────────

class ActiveBookingModel {
  const ActiveBookingModel({
    required this.bookingUuid,
    required this.tripUuid,
    required this.tripStatus,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    this.departureLat,
    this.departureLng,
    this.arrivalLat,
    this.arrivalLng,
    this.price,
    required this.driverName,
    required this.driverPhone,
    required this.driverInitials,
    required this.driverVehicle,
    required this.driverPlate,
    this.driverAvatar,
  });

  final String bookingUuid;
  final String tripUuid;
  final String tripStatus;
  final String departureCity;
  final String arrivalCity;
  final String departureTime;
  final double? departureLat;
  final double? departureLng;
  final double? arrivalLat;
  final double? arrivalLng;
  final String? price;
  final String driverName;
  final String driverPhone;
  final String driverInitials;
  final String driverVehicle;
  final String driverPlate;
  final String? driverAvatar;

  factory ActiveBookingModel.fromJson(Map<String, dynamic> j) {
    final trip   = j['trip']   as Map<String, dynamic>? ?? {};
    final driver = trip['driver'] as Map<String, dynamic>? ?? {};
    final profile = driver['profile'] as Map<String, dynamic>? ?? {};
    final vehicle = driver['vehicle'] as Map<String, dynamic>? ?? {};
    final firstName = profile['first_name']?.toString() ?? '';
    final lastName  = profile['last_name']?.toString() ?? '';
    final fullName  = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    final initials  = [firstName, lastName]
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase())
        .join('');
    final brand = vehicle['brand']?.toString() ?? '';
    final model = vehicle['model']?.toString() ?? '';
    final vehicleLabel = [brand, model].where((s) => s.isNotEmpty).join(' ');
    return ActiveBookingModel(
      bookingUuid:   j['uuid']?.toString() ?? '',
      tripUuid:      trip['uuid']?.toString() ?? '',
      tripStatus:    trip['status']?.toString() ?? 'pending',
      departureCity: trip['departure_city']?.toString() ?? '',
      arrivalCity:   trip['arrival_city']?.toString() ?? '',
      departureTime: trip['departure_time']?.toString() ?? '',
      departureLat:  (trip['departure_latitude'] as num?)?.toDouble(),
      departureLng:  (trip['departure_longitude'] as num?)?.toDouble(),
      arrivalLat:    (trip['arrival_latitude'] as num?)?.toDouble(),
      arrivalLng:    (trip['arrival_longitude'] as num?)?.toDouble(),
      price:         trip['price']?.toString(),
      driverName:    fullName.isNotEmpty ? fullName : driver['name']?.toString() ?? '',
      driverPhone:   driver['phone']?.toString() ?? '',
      driverInitials: initials,
      driverVehicle:  vehicleLabel,
      driverPlate:    vehicle['plate']?.toString() ?? '',
      driverAvatar:   profile['avatar']?.toString(),
    );
  }
}

// ── Modèle trajet actif conducteur ──────────────────────────────────────────

class ActiveDriverTripModel {
  const ActiveDriverTripModel({
    required this.tripUuid,
    required this.status,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    this.departureLat,
    this.departureLng,
    this.arrivalLat,
    this.arrivalLng,
    required this.passengers,
  });

  final String tripUuid;
  final String status;
  final String departureCity;
  final String arrivalCity;
  final String departureTime;
  final double? departureLat;
  final double? departureLng;
  final double? arrivalLat;
  final double? arrivalLng;
  final List<ActivePassengerModel> passengers;

  factory ActiveDriverTripModel.fromJson(Map<String, dynamic> j) {
    final bookings = j['bookings'] as List? ?? [];
    return ActiveDriverTripModel(
      tripUuid:      j['uuid']?.toString() ?? '',
      status:        j['status']?.toString() ?? 'pending',
      departureCity: j['departure_city']?.toString() ?? '',
      arrivalCity:   j['arrival_city']?.toString() ?? '',
      departureTime: j['departure_time']?.toString() ?? '',
      departureLat:  (j['departure_latitude'] as num?)?.toDouble(),
      departureLng:  (j['departure_longitude'] as num?)?.toDouble(),
      arrivalLat:    (j['arrival_latitude'] as num?)?.toDouble(),
      arrivalLng:    (j['arrival_longitude'] as num?)?.toDouble(),
      passengers: bookings
          .where((b) => (b as Map)['status']?.toString() == 'confirmed')
          .map((b) => ActivePassengerModel.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ActivePassengerModel {
  const ActivePassengerModel({
    required this.name,
    required this.phone,
    required this.seats,
    this.pickupLat,
    this.pickupLng,
    this.avatar,
  });

  final String name;
  final String phone;
  final int seats;
  final double? pickupLat;
  final double? pickupLng;
  final String? avatar;

  factory ActivePassengerModel.fromJson(Map<String, dynamic> j) {
    final p = j['passenger'] as Map<String, dynamic>? ?? {};
    final profile = p['profile'] as Map<String, dynamic>? ?? {};
    final firstName = profile['first_name']?.toString() ?? '';
    final lastName  = profile['last_name']?.toString() ?? '';
    final fullName  = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    return ActivePassengerModel(
      name:       fullName.isNotEmpty ? fullName : 'Passager',
      phone:      p['phone']?.toString() ?? '',
      seats:      (j['seats'] as num?)?.toInt() ?? 1,
      pickupLat:  (p['pickup_latitude']  as num?)?.toDouble(),
      pickupLng:  (p['pickup_longitude'] as num?)?.toDouble(),
      avatar:     profile['avatar']?.toString(),
    );
  }
}
