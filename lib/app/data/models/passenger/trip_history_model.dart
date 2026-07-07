class TripRecord {
  const TripRecord({
    required this.id,
    this.tripUuid = '',
    required this.origin,
    required this.destination,
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
  final String destination;
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
        id: j['uuid'] as String? ?? '',
        tripUuid: j['trip_uuid'] as String? ?? '',
        origin: j['origin'] as String? ?? '',
        destination: j['destination'] as String? ?? '',
        date: j['date'] as String? ?? '',
        time: j['time'] as String? ?? '',
        driverName: j['driver_name'] as String? ?? '',
        vehicle: j['vehicle'] as String? ?? '',
        vehiclePlate: j['vehicle_plate'] as String? ?? '',
        price: j['price'] as int? ?? 0,
        seats: j['seats'] as int? ?? 1,
        status: j['status'] as String? ?? 'upcoming',
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
        upcoming: j['upcoming'] as int? ?? 0,
        completed: j['completed'] as int? ?? 0,
        cancelled: j['cancelled'] as int? ?? 0,
      );
}

class TripHistoryResult {
  const TripHistoryResult({required this.counts, required this.trips});

  final TripHistoryCounts counts;
  final List<TripRecord> trips;

  factory TripHistoryResult.fromJson(Map<String, dynamic> j) =>
      TripHistoryResult(
        counts: TripHistoryCounts.fromJson(
            j['counts'] as Map<String, dynamic>),
        trips: (j['trips'] as List<dynamic>? ?? [])
            .map((e) => TripRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
