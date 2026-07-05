class EndTripConfirmation {
  const EndTripConfirmation({
    required this.bookingUuid,
    required this.name,
    required this.initial,
    required this.hasConfirmed,
    required this.seats,
  });

  final String bookingUuid;
  final String name;
  final String initial;
  final bool hasConfirmed;
  final int seats;

  factory EndTripConfirmation.fromJson(Map<String, dynamic> j) =>
      EndTripConfirmation(
        bookingUuid: j['booking_uuid'] as String? ?? '',
        name: j['name'] as String? ?? '',
        initial: j['initial'] as String? ?? '',
        hasConfirmed: j['has_confirmed'] as bool? ?? false,
        seats: j['seats'] as int? ?? 1,
      );
}

class EndTripSummaryModel {
  const EndTripSummaryModel({
    required this.tripRoute,
    required this.realDuration,
    required this.distanceKm,
    required this.passengersCount,
    required this.grossRevenue,
    required this.commission,
    required this.commissionRate,
    required this.netRevenue,
    required this.confirmedCount,
    required this.allConfirmed,
    required this.availableDate,
    required this.confirmations,
    required this.tripStatus,
  });

  final String tripRoute;
  final String realDuration;
  final double distanceKm;
  final int passengersCount;
  final double grossRevenue;
  final double commission;
  final int commissionRate;
  final double netRevenue;
  final int confirmedCount;
  final bool allConfirmed;
  final String availableDate;
  final List<EndTripConfirmation> confirmations;
  final String tripStatus;

  factory EndTripSummaryModel.fromJson(Map<String, dynamic> j) =>
      EndTripSummaryModel(
        tripRoute: j['trip_route'] as String? ?? '',
        realDuration: j['real_duration'] as String? ?? '',
        distanceKm: (j['distance_km'] as num?)?.toDouble() ?? 0.0,
        passengersCount: j['passengers_count'] as int? ?? 0,
        grossRevenue: (j['gross_revenue'] as num?)?.toDouble() ?? 0.0,
        commission: (j['commission'] as num?)?.toDouble() ?? 0.0,
        commissionRate: j['commission_rate'] as int? ?? 0,
        netRevenue: (j['net_revenue'] as num?)?.toDouble() ?? 0.0,
        confirmedCount: j['confirmed_count'] as int? ?? 0,
        allConfirmed: j['all_confirmed'] as bool? ?? false,
        availableDate: j['available_date'] as String? ?? '',
        confirmations: (j['confirmations'] as List<dynamic>? ?? [])
            .map((e) => EndTripConfirmation.fromJson(e as Map<String, dynamic>))
            .toList(),
        tripStatus: j['trip_status'] as String? ?? '',
      );
}
