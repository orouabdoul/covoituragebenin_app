class PreDepartureStop {
  const PreDepartureStop({
    required this.index,
    required this.type,
    required this.passengerName,
    required this.address,
    required this.eta,
    required this.bookingUuid,
    required this.phone,
    required this.seats,
  });

  final int index;
  final String type;
  final String passengerName;
  final String address;
  final String eta;
  final String bookingUuid;
  final String phone;
  final int seats;

  bool get isPickup => type == 'pickup';

  factory PreDepartureStop.fromJson(Map<String, dynamic> j) => PreDepartureStop(
        index: j['index'] as int? ?? 0,
        type: j['type'] as String? ?? 'pickup',
        passengerName: j['passenger_name'] as String? ?? '',
        address: j['address'] as String? ?? '',
        eta: j['eta'] as String? ?? '',
        bookingUuid: j['booking_uuid'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        seats: j['seats'] as int? ?? 1,
      );
}

class PreDepartureChecklistItem {
  const PreDepartureChecklistItem({
    required this.key,
    required this.label,
    required this.isDone,
  });

  final String key;
  final String label;
  final bool isDone;

  factory PreDepartureChecklistItem.fromJson(Map<String, dynamic> j) =>
      PreDepartureChecklistItem(
        key: j['key'] as String? ?? '',
        label: j['label'] as String? ?? '',
        isDone: j['is_done'] as bool? ?? false,
      );
}

class PreDepartureTripSummary {
  const PreDepartureTripSummary({
    required this.uuid,
    required this.origin,
    required this.destination,
    required this.departureTimeFormatted,
    required this.distanceKm,
    required this.durationLabel,
    required this.passengersCount,
    required this.bookingMode,
    this.estimatedArrivalTime,
  });

  final String uuid;
  final String origin;
  final String destination;
  final String departureTimeFormatted;
  final double distanceKm;
  final String durationLabel;
  final int passengersCount;
  final String bookingMode;
  final String? estimatedArrivalTime;

  factory PreDepartureTripSummary.fromJson(Map<String, dynamic> j) =>
      PreDepartureTripSummary(
        uuid: j['uuid'] as String? ?? '',
        origin: j['origin'] as String? ?? '',
        destination: j['destination'] as String? ?? '',
        departureTimeFormatted: j['departure_time_formatted'] as String? ?? '',
        distanceKm: (j['distance_km'] as num?)?.toDouble() ?? 0.0,
        durationLabel: j['duration_label'] as String? ?? '',
        passengersCount: j['passengers_count'] as int? ?? 0,
        bookingMode: j['booking_mode'] as String? ?? '',
        estimatedArrivalTime: j['estimated_arrival_time'] as String?,
      );
}

class PreDepartureModel {
  const PreDepartureModel({
    required this.trip,
    required this.allGreen,
    required this.checklist,
    required this.stops,
    required this.pendingApprovals,
  });

  final PreDepartureTripSummary trip;
  final bool allGreen;
  final List<PreDepartureChecklistItem> checklist;
  final List<PreDepartureStop> stops;
  final int pendingApprovals;

  factory PreDepartureModel.fromJson(Map<String, dynamic> j) => PreDepartureModel(
        trip: PreDepartureTripSummary.fromJson(j['trip'] as Map<String, dynamic>),
        allGreen: j['all_green'] as bool? ?? false,
        checklist: (j['checklist'] as List<dynamic>? ?? [])
            .map((e) => PreDepartureChecklistItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        stops: (j['stops'] as List<dynamic>? ?? [])
            .map((e) => PreDepartureStop.fromJson(e as Map<String, dynamic>))
            .toList(),
        pendingApprovals: j['pending_approvals'] as int? ?? 0,
      );
}
