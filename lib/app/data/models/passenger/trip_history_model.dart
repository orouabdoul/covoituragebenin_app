class TripRecord {
  const TripRecord({
    required this.id,
    this.tripUuid = '',
    required this.origin,
    this.originArrondissement = '',
    this.originNeighborhood = '',
    this.originPoint = '',
    required this.destination,
    this.destinationArrondissement = '',
    this.destinationNeighborhood = '',
    this.destinationPoint = '',
    required this.date,
    required this.time,
    this.datetimeLabel = '',
    required this.driverName,
    required this.vehicle,
    required this.vehiclePlate,
    required this.price,
    required this.seats,
    required this.status,
    this.rating,
    this.distanceKm = 0.0,
    this.durationLabel = '',
  });

  final String id;          // booking UUID
  final String tripUuid;
  final String origin;
  final String originArrondissement;
  final String originNeighborhood;
  final String originPoint;
  final String destination;
  final String destinationArrondissement;
  final String destinationNeighborhood;
  final String destinationPoint;
  final String date;
  final String time;
  final String datetimeLabel;
  final String driverName;
  final String vehicle;
  final String vehiclePlate;
  final int price;
  final int seats;
  final String status; // 'upcoming' | 'completed' | 'cancelled'
  final double? rating;
  final double distanceKm;
  final String durationLabel;

  String get displayOrigin {
    final parts = [origin, originArrondissement, originNeighborhood]
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.join(', ') : origin;
  }

  String get displayDestination {
    final parts = [destination, destinationArrondissement, destinationNeighborhood]
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.join(', ') : destination;
  }

  factory TripRecord.fromJson(Map<String, dynamic> j) => TripRecord(
        id: (j['uuid'] ?? j['id'] ?? '').toString(),
        tripUuid: (j['trip_uuid'] ?? '').toString(),
        origin: (j['origin'] ?? '').toString(),
        originArrondissement: (j['departure_arrondissement'] ?? j['origin_arrondissement'] ?? '').toString(),
        originNeighborhood: (j['departure_neighborhood'] ?? j['origin_neighborhood'] ?? '').toString(),
        originPoint: (j['departure_point'] ?? j['origin_point'] ?? '').toString(),
        destination: (j['destination'] ?? '').toString(),
        destinationArrondissement: (j['arrival_arrondissement'] ?? j['destination_arrondissement'] ?? '').toString(),
        destinationNeighborhood: (j['arrival_neighborhood'] ?? j['destination_neighborhood'] ?? '').toString(),
        destinationPoint: (j['arrival_point'] ?? j['destination_point'] ?? '').toString(),
        date: (j['date'] ?? '').toString(),
        time: (j['time'] ?? '').toString(),
        datetimeLabel: (j['datetime_label'] ?? '').toString(),
        driverName: (j['driver_name'] ?? '').toString(),
        vehicle: (j['vehicle'] ?? '').toString(),
        vehiclePlate: (j['vehicle_plate'] ?? '').toString(),
        price: (j['price'] as num?)?.toInt() ?? 0,
        seats: (j['seats'] as num?)?.toInt() ?? 1,
        status: (j['status'] ?? 'upcoming').toString(),
        rating: (j['rating'] as num?)?.toDouble(),
        distanceKm: (j['distance_km'] as num?)?.toDouble() ?? 0.0,
        durationLabel: (j['duration_label'] ?? j['duration'] ?? '').toString(),
      );
}

class TripHistoryCounts {
  const TripHistoryCounts({
    required this.upcoming,
    required this.completed,
    required this.cancelled,
  });

  final int upcoming;
  final int completed;
  final int cancelled;

  factory TripHistoryCounts.fromJson(Map<String, dynamic> j) =>
      TripHistoryCounts(
        upcoming: (j['upcoming'] as num?)?.toInt() ?? 0,
        completed: (j['completed'] as num?)?.toInt() ?? 0,
        cancelled: (j['cancelled'] as num?)?.toInt() ?? 0,
      );
}

class TripHistoryResult {
  const TripHistoryResult({required this.counts, required this.trips});

  final TripHistoryCounts counts;
  final List<TripRecord> trips;

  factory TripHistoryResult.fromJson(Map<String, dynamic> j) {
    final rawCounts = j['counts'];
    final counts = rawCounts is Map<String, dynamic>
        ? TripHistoryCounts.fromJson(rawCounts)
        : const TripHistoryCounts(upcoming: 0, completed: 0, cancelled: 0);
    final trips = (j['trips'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => TripRecord.fromJson(e))
        .toList();
    return TripHistoryResult(counts: counts, trips: trips);
  }
}
