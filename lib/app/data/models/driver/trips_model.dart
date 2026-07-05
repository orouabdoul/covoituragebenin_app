class FilterCountsData {
  const FilterCountsData({
    required this.all,
    required this.pending,
    required this.active,
    required this.completed,
    required this.cancelled,
  });

  final int all;
  final int pending;
  final int active;
  final int completed;
  final int cancelled;

  factory FilterCountsData.fromJson(Map<String, dynamic> json) =>
      FilterCountsData(
        all: (json['all'] as num?)?.toInt() ?? 0,
        pending: (json['pending'] as num?)?.toInt() ?? 0,
        active: (json['active'] as num?)?.toInt() ?? 0,
        completed: (json['completed'] as num?)?.toInt() ?? 0,
        cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
      );
}

class TripPassengerSummaryData {
  const TripPassengerSummaryData({
    required this.initials,
    required this.name,
  });

  final String initials;
  final String name;

  factory TripPassengerSummaryData.fromJson(Map<String, dynamic> json) =>
      TripPassengerSummaryData(
        initials: (json['initials'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
      );
}

class TripPrimaryActionData {
  const TripPrimaryActionData({
    required this.label,
    required this.enabled,
    required this.action,
  });

  final String label;
  final bool enabled;
  final String action;

  factory TripPrimaryActionData.fromJson(Map<String, dynamic> json) =>
      TripPrimaryActionData(
        label: (json['label'] as String?) ?? '',
        enabled: (json['enabled'] as bool?) ?? true,
        action: (json['action'] as String?) ?? '',
      );
}

class TripItemData {
  const TripItemData({
    required this.uuid,
    required this.status,
    required this.statusLabel,
    required this.origin,
    required this.originPoint,
    required this.destination,
    required this.destinationPoint,
    required this.departureTime,
    required this.departureTimeLabel,
    required this.seatsTotal,
    required this.seatsBooked,
    required this.pricePerSeat,
    required this.priceLabel,
    required this.publishedAgo,
    required this.passengers,
    required this.canEdit,
    required this.canCancel,
    this.primaryAction,
    this.note,
  });

  final String uuid;
  final String status;
  final String statusLabel;
  final String origin;
  final String originPoint;
  final String destination;
  final String destinationPoint;
  final String departureTime;
  final String departureTimeLabel;
  final int seatsTotal;
  final int seatsBooked;
  final int pricePerSeat;
  final String priceLabel;
  final String publishedAgo;
  final List<TripPassengerSummaryData> passengers;
  final bool canEdit;
  final bool canCancel;
  final TripPrimaryActionData? primaryAction;
  final String? note;

  factory TripItemData.fromJson(Map<String, dynamic> json) => TripItemData(
        uuid: (json['uuid'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        statusLabel: (json['status_label'] as String?) ?? '',
        origin: (json['origin'] as String?) ?? '',
        originPoint: (json['origin_point'] as String?) ?? '',
        destination: (json['destination'] as String?) ?? '',
        destinationPoint: (json['destination_point'] as String?) ?? '',
        departureTime: (json['departure_time'] as String?) ?? '',
        departureTimeLabel: (json['departure_time_label'] as String?) ?? '',
        seatsTotal: (json['seats_total'] as num?)?.toInt() ?? 0,
        seatsBooked: (json['seats_booked'] as num?)?.toInt() ?? 0,
        pricePerSeat: (json['price_per_seat'] as num?)?.toInt() ?? 0,
        priceLabel: (json['price_label'] as String?) ?? '',
        publishedAgo: (json['published_ago'] as String?) ?? '',
        passengers: (json['passengers'] as List?)
                ?.map((p) => TripPassengerSummaryData.fromJson(
                    p as Map<String, dynamic>))
                .toList() ??
            [],
        canEdit: (json['can_edit'] as bool?) ?? false,
        canCancel: (json['can_cancel'] as bool?) ?? false,
        primaryAction: json['primary_action'] != null
            ? TripPrimaryActionData.fromJson(
                json['primary_action'] as Map<String, dynamic>)
            : null,
        note: json['note'] as String?,
      );
}

class TripsPaginationData {
  const TripsPaginationData({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  factory TripsPaginationData.fromJson(Map<String, dynamic> json) =>
      TripsPaginationData(
        currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
        lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
        perPage: (json['per_page'] as num?)?.toInt() ?? 15,
        total: (json['total'] as num?)?.toInt() ?? 0,
      );
}

class TripsModel {
  const TripsModel({
    required this.filterCounts,
    required this.trips,
    required this.pagination,
  });

  final FilterCountsData filterCounts;
  final List<TripItemData> trips;
  final TripsPaginationData pagination;

  factory TripsModel.fromJson(Map<String, dynamic> json) => TripsModel(
        filterCounts: FilterCountsData.fromJson(
            (json['filter_counts'] as Map<String, dynamic>?) ?? {}),
        trips: (json['trips'] as List?)
                ?.map(
                    (t) => TripItemData.fromJson(t as Map<String, dynamic>))
                .toList() ??
            [],
        pagination: TripsPaginationData.fromJson(
            (json['pagination'] as Map<String, dynamic>?) ?? {}),
      );
}

// ── Passengers endpoint ────────────────────────────────────────────────────

class TripPassengerDetailData {
  const TripPassengerDetailData({
    required this.bookingUuid,
    required this.fullName,
    required this.initials,
    required this.phone,
    required this.seatsBooked,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.bookedAt,
  });

  final String bookingUuid;
  final String fullName;
  final String initials;
  final String phone;
  final int seatsBooked;
  final String bookingStatus;
  final String paymentStatus;
  final String bookedAt;

  factory TripPassengerDetailData.fromJson(Map<String, dynamic> json) =>
      TripPassengerDetailData(
        bookingUuid: (json['booking_uuid'] as String?) ?? '',
        fullName: (json['full_name'] as String?) ?? '',
        initials: (json['initials'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
        seatsBooked: (json['seats_booked'] as num?)?.toInt() ?? 1,
        bookingStatus: (json['booking_status'] as String?) ?? '',
        paymentStatus: (json['payment_status'] as String?) ?? '',
        bookedAt: (json['booked_at'] as String?) ?? '',
      );
}

class TripPassengersModel {
  const TripPassengersModel({
    required this.tripUuid,
    required this.tripRoute,
    required this.totalBooked,
    required this.passengers,
  });

  final String tripUuid;
  final String tripRoute;
  final int totalBooked;
  final List<TripPassengerDetailData> passengers;

  factory TripPassengersModel.fromJson(Map<String, dynamic> json) =>
      TripPassengersModel(
        tripUuid: (json['trip_uuid'] as String?) ?? '',
        tripRoute: (json['trip_route'] as String?) ?? '',
        totalBooked: (json['total_booked'] as num?)?.toInt() ?? 0,
        passengers: (json['passengers'] as List?)
                ?.map((p) => TripPassengerDetailData.fromJson(
                    p as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
