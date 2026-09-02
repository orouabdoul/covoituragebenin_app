class TripRecord {
  const TripRecord({
    required this.id,
    this.tripUuid = '',
    required this.origin,
    this.originArrondissement = '',
    required this.destination,
    this.destinationArrondissement = '',
    required this.date,
    required this.time,
    required this.driverName,
    required this.vehicle,
    required this.vehiclePlate,
    required this.price,
    required this.seats,
    required this.status,
    this.rating,
  });

  final String id;          // booking UUID
  final String tripUuid;
  final String origin;
  final String originArrondissement;
  final String destination;
  final String destinationArrondissement;
  final String date;
  final String time;
  final String driverName;
  final String vehicle;
  final String vehiclePlate;
  final int price;
  final int seats;
  final String status; // 'upcoming' | 'completed' | 'cancelled'
  final double? rating;

  factory TripRecord.fromJson(Map<String, dynamic> j) => TripRecord(
        id: (j['uuid'] ?? j['id'] ?? '').toString(),
        tripUuid: (j['trip_uuid'] ?? '').toString(),
        origin: (j['origin'] ?? '').toString(),
        originArrondissement: (j['origin_arrondissement'] ?? '').toString(),
        destination: (j['destination'] ?? '').toString(),
        destinationArrondissement: (j['destination_arrondissement'] ?? '').toString(),
        date: (j['date'] ?? '').toString(),
        time: (j['time'] ?? '').toString(),
        driverName: (j['driver_name'] ?? '').toString(),
        vehicle: (j['vehicle'] ?? '').toString(),
        vehiclePlate: (j['vehicle_plate'] ?? '').toString(),
        price: (j['price'] as num?)?.toInt() ?? 0,
        seats: (j['seats'] as num?)?.toInt() ?? 1,
        status: (j['status'] ?? 'upcoming').toString(),
        rating: (j['rating'] as num?)?.toDouble(),
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
