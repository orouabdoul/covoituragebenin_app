// ── Confirmation Context ───────────────────────────────────────────────────

class ConfirmationContextTripInfo {
  const ConfirmationContextTripInfo({
    required this.uuid,
    required this.availableSeats,
    required this.maxPerBooking,
    required this.pricePerSeat,
    required this.bookingMode,
    required this.distanceKm,
  });

  final String uuid;
  final int availableSeats;
  final int maxPerBooking;
  final int pricePerSeat;
  final String bookingMode; // 'approval' | 'instant'
  final String distanceKm;

  factory ConfirmationContextTripInfo.fromJson(Map<String, dynamic> j) =>
      ConfirmationContextTripInfo(
        uuid: j['uuid'] as String? ?? '',
        availableSeats: j['available_seats'] as int? ?? 0,
        maxPerBooking: j['max_per_booking'] as int? ?? 1,
        pricePerSeat: j['price_per_seat'] as int? ?? 0,
        bookingMode: j['booking_mode'] as String? ?? 'approval',
        distanceKm: j['distance_km'] as String? ?? '',
      );
}

class ApiPaymentMethod {
  const ApiPaymentMethod({
    required this.provider,
    required this.title,
    required this.description,
    required this.iconName,
    required this.color,
  });

  final String provider;
  final String title;
  final String description;
  final String iconName;
  final int color;

  factory ApiPaymentMethod.fromJson(Map<String, dynamic> j) => ApiPaymentMethod(
        provider: j['provider'] as String? ?? '',
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        iconName: j['icon'] as String? ?? 'phone_android',
        color: j['color'] as int? ?? 0xFF00A86B,
      );
}

class ConfirmationContextModel {
  const ConfirmationContextModel({
    required this.trip,
    required this.commissionRate,
    required this.userPhone,
    required this.paymentMethods,
  });

  final ConfirmationContextTripInfo trip;
  final int commissionRate;
  final String userPhone;
  final List<ApiPaymentMethod> paymentMethods;

  factory ConfirmationContextModel.fromJson(Map<String, dynamic> j) =>
      ConfirmationContextModel(
        trip: ConfirmationContextTripInfo.fromJson(j['trip'] as Map<String, dynamic>),
        commissionRate: j['commission_rate'] as int? ?? 10,
        userPhone: j['user_phone'] as String? ?? '',
        paymentMethods: (j['payment_methods'] as List<dynamic>? ?? [])
            .map((e) => ApiPaymentMethod.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Live Tracking ──────────────────────────────────────────────────────────

class LiveTrackingRideInfo {
  const LiveTrackingRideInfo({
    required this.driverName,
    required this.driverInitials,
    required this.rating,
    required this.vehicle,
    required this.vehiclePlate,
    required this.driverPhone,
  });

  final String driverName;
  final String driverInitials;
  final String rating;
  final String vehicle;
  final String vehiclePlate;
  final String driverPhone;

  factory LiveTrackingRideInfo.fromJson(Map<String, dynamic> j) =>
      LiveTrackingRideInfo(
        driverName: j['driver_name'] as String? ?? '',
        driverInitials: j['driver_initials'] as String? ?? '',
        rating: j['rating'] as String? ?? '',
        vehicle: j['vehicle'] as String? ?? '',
        vehiclePlate: j['vehicle_plate'] as String? ?? '',
        driverPhone: j['driver_phone'] as String? ?? '',
      );
}

class LiveTrackingModel {
  const LiveTrackingModel({
    required this.lat,
    required this.lng,
    required this.speedKmh,
    required this.etaMinutes,
    required this.distanceRemainingKm,
    required this.tripStatus,
    required this.tripEnded,
    required this.ride,
  });

  final double lat;
  final double lng;
  final int speedKmh;
  final int etaMinutes;
  final double distanceRemainingKm;
  final String tripStatus;
  final bool tripEnded;
  final LiveTrackingRideInfo ride;

  factory LiveTrackingModel.fromJson(Map<String, dynamic> j) => LiveTrackingModel(
        lat: (j['lat'] as num?)?.toDouble() ?? 0,
        lng: (j['lng'] as num?)?.toDouble() ?? 0,
        speedKmh: j['speed_kmh'] as int? ?? 0,
        etaMinutes: j['eta_minutes'] as int? ?? 0,
        distanceRemainingKm: (j['distance_remaining_km'] as num?)?.toDouble() ?? 0,
        tripStatus: j['trip_status'] as String? ?? 'active',
        tripEnded: j['trip_ended'] as bool? ?? false,
        ride: LiveTrackingRideInfo.fromJson(j['ride'] as Map<String, dynamic>),
      );
}

// ── Payment Success ────────────────────────────────────────────────────────

class PaymentSuccessRide {
  const PaymentSuccessRide({
    required this.uuid,
    required this.driverName,
    required this.driverInitials,
    required this.rating,
    required this.reviewCount,
    required this.vehicle,
    required this.vehiclePlate,
    required this.origin,
    required this.destination,
    required this.departureTime,
  });

  final String uuid;
  final String driverName;
  final String driverInitials;
  final String rating;
  final int reviewCount;
  final String vehicle;
  final String vehiclePlate;
  final String origin;
  final String destination;
  final String departureTime;

  factory PaymentSuccessRide.fromJson(Map<String, dynamic> j) => PaymentSuccessRide(
        uuid: j['uuid'] as String? ?? '',
        driverName: j['driver_name'] as String? ?? '',
        driverInitials: j['driver_initials'] as String? ?? '',
        rating: j['rating'] as String? ?? '',
        reviewCount: j['review_count'] as int? ?? 0,
        vehicle: j['vehicle'] as String? ?? '',
        vehiclePlate: j['vehicle_plate'] as String? ?? '',
        origin: j['origin'] as String? ?? '',
        destination: j['destination'] as String? ?? '',
        departureTime: j['departure_time'] as String? ?? '',
      );
}

class PaymentSuccessModel {
  const PaymentSuccessModel({
    required this.transactionRef,
    required this.amountPaid,
    required this.formattedAmount,
    required this.driverPhone,
    required this.conversationUuid,
    required this.reservedSeats,
    required this.ride,
  });

  final String transactionRef;
  final int amountPaid;
  final String formattedAmount;
  final String driverPhone;
  final String conversationUuid;
  final int reservedSeats;
  final PaymentSuccessRide ride;

  factory PaymentSuccessModel.fromJson(Map<String, dynamic> j) => PaymentSuccessModel(
        transactionRef: j['transaction_ref'] as String? ?? '',
        amountPaid: j['amount_paid'] as int? ?? 0,
        formattedAmount: j['formatted_amount'] as String? ?? '',
        driverPhone: j['driver_phone'] as String? ?? '',
        conversationUuid: j['conversation_uuid'] as String? ?? '',
        reservedSeats: j['reserved_seats'] as int? ?? 1,
        ride: PaymentSuccessRide.fromJson(j['ride'] as Map<String, dynamic>),
      );
}

// ── Reservations List ──────────────────────────────────────────────────────

class ActiveTripBanner {
  const ActiveTripBanner({
    required this.uuid,
    required this.departureCity,
    required this.arrivalCity,
  });

  final String uuid;
  final String departureCity;
  final String arrivalCity;

  factory ActiveTripBanner.fromJson(Map<String, dynamic> j) => ActiveTripBanner(
        uuid: j['uuid'] as String? ?? '',
        departureCity: j['departure_city'] as String? ?? '',
        arrivalCity: j['arrival_city'] as String? ?? '',
      );
}

class ReservationStatusTabApi {
  const ReservationStatusTabApi({
    required this.status,
    required this.label,
    required this.count,
  });

  final String status;
  final String label;
  final int count;

  factory ReservationStatusTabApi.fromJson(Map<String, dynamic> j) =>
      ReservationStatusTabApi(
        status: j['status'] as String? ?? '',
        label: j['label'] as String? ?? '',
        count: j['count'] as int? ?? 0,
      );
}

class ReservationApiItem {
  const ReservationApiItem({
    required this.uuid,
    required this.status,
    required this.isPaid,
    this.cancelReason,
    required this.timeAgo,
    required this.driverName,
    required this.driverInitials,
    required this.rating,
    required this.reviewCount,
    required this.totalPrice,
    required this.seatsCount,
    required this.departureCity,
    required this.departureNote,
    required this.arrivalCity,
    required this.arrivalNote,
    required this.departureTime,
    required this.departureDate,
    required this.vehicle,
    required this.vehiclePlate,
    this.etaMinutes,
    required this.hasRated,
    required this.refundStatus,
  });

  final String uuid;
  final String status;
  final bool isPaid;
  final String? cancelReason;
  final String timeAgo;
  final String driverName;
  final String driverInitials;
  final double rating;
  final String reviewCount;
  final String totalPrice;
  final int seatsCount;
  final String departureCity;
  final String departureNote;
  final String arrivalCity;
  final String arrivalNote;
  final String departureTime;
  final String departureDate;
  final String vehicle;
  final String vehiclePlate;
  final int? etaMinutes;
  final bool hasRated;
  final String refundStatus;

  factory ReservationApiItem.fromJson(Map<String, dynamic> j) => ReservationApiItem(
        uuid: j['uuid'] as String? ?? '',
        status: j['status'] as String? ?? 'pending',
        isPaid: j['is_paid'] as bool? ?? false,
        cancelReason: j['cancel_reason'] as String?,
        timeAgo: j['time_ago'] as String? ?? '',
        driverName: j['driver_name'] as String? ?? '',
        driverInitials: j['driver_initials'] as String? ?? '',
        rating: (j['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: j['review_count'] as String? ?? '',
        totalPrice: j['total_price'] as String? ?? '',
        seatsCount: j['seats_count'] as int? ?? 1,
        departureCity: j['departure_city'] as String? ?? '',
        departureNote: j['departure_note'] as String? ?? '',
        arrivalCity: j['arrival_city'] as String? ?? '',
        arrivalNote: j['arrival_note'] as String? ?? '',
        departureTime: j['departure_time'] as String? ?? '',
        departureDate: j['departure_date'] as String? ?? '',
        vehicle: j['vehicle'] as String? ?? '',
        vehiclePlate: j['vehicle_plate'] as String? ?? '',
        etaMinutes: j['eta_minutes'] as int?,
        hasRated: j['has_rated'] as bool? ?? false,
        refundStatus: j['refund_status'] as String? ?? 'none',
      );
}

class ReservationsPageModel {
  const ReservationsPageModel({
    this.activeTrip,
    required this.statusTabs,
    required this.items,
  });

  final ActiveTripBanner? activeTrip;
  final List<ReservationStatusTabApi> statusTabs;
  final List<ReservationApiItem> items;

  factory ReservationsPageModel.fromJson(Map<String, dynamic> j) => ReservationsPageModel(
        activeTrip: j['active_trip'] != null
            ? ActiveTripBanner.fromJson(j['active_trip'] as Map<String, dynamic>)
            : null,
        statusTabs: (j['status_tabs'] as List<dynamic>? ?? [])
            .map((e) => ReservationStatusTabApi.fromJson(e as Map<String, dynamic>))
            .toList(),
        items: (j['items'] as List<dynamic>? ?? [])
            .map((e) => ReservationApiItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Invoice ────────────────────────────────────────────────────────────────

class InvoiceModel {
  const InvoiceModel({
    required this.invoiceRef,
    required this.issuedAt,
    required this.passengerName,
    required this.driverName,
    required this.route,
    required this.departureDate,
    required this.seats,
    required this.pricePerSeat,
    required this.totalAmount,
    required this.paymentMethod,
    required this.transactionRef,
    required this.bookingRef,
  });

  final String invoiceRef;
  final String issuedAt;
  final String passengerName;
  final String driverName;
  final String route;
  final String departureDate;
  final int seats;
  final String pricePerSeat;
  final String totalAmount;
  final String paymentMethod;
  final String transactionRef;
  final String bookingRef;

  factory InvoiceModel.fromJson(Map<String, dynamic> j) => InvoiceModel(
        invoiceRef: j['invoice_ref'] as String? ?? '',
        issuedAt: j['issued_at'] as String? ?? '',
        passengerName: j['passenger_name'] as String? ?? '',
        driverName: j['driver_name'] as String? ?? '',
        route: j['route'] as String? ?? '',
        departureDate: j['departure_date'] as String? ?? '',
        seats: j['seats'] as int? ?? 1,
        pricePerSeat: j['price_per_seat'] as String? ?? '',
        totalAmount: j['total_amount'] as String? ?? '',
        paymentMethod: j['payment_method'] as String? ?? '',
        transactionRef: j['transaction_ref'] as String? ?? '',
        bookingRef: j['booking_ref'] as String? ?? '',
      );
}

// ── Trip Confirmation Context ──────────────────────────────────────────────

class TripConfirmationRide {
  const TripConfirmationRide({
    required this.origin,
    required this.destination,
    required this.duration,
    required this.driverName,
    required this.driverInitials,
  });

  final String origin;
  final String destination;
  final String duration;
  final String driverName;
  final String driverInitials;

  factory TripConfirmationRide.fromJson(Map<String, dynamic> j) => TripConfirmationRide(
        origin: j['origin'] as String? ?? '',
        destination: j['destination'] as String? ?? '',
        duration: j['duration'] as String? ?? '',
        driverName: j['driver_name'] as String? ?? '',
        driverInitials: j['driver_initials'] as String? ?? '',
      );
}

class TripConfirmationContextModel {
  const TripConfirmationContextModel({
    required this.ride,
    required this.alreadyReviewed,
    this.passengerConfirmedAt,
  });

  final TripConfirmationRide ride;
  final bool alreadyReviewed;
  final String? passengerConfirmedAt;

  factory TripConfirmationContextModel.fromJson(Map<String, dynamic> j) =>
      TripConfirmationContextModel(
        ride: TripConfirmationRide.fromJson(j['ride'] as Map<String, dynamic>),
        alreadyReviewed: j['already_reviewed'] as bool? ?? false,
        passengerConfirmedAt: j['passenger_confirmed_at'] as String?,
      );
}

// ── Approval Status ────────────────────────────────────────────────────────

class ApprovalStatusRide {
  const ApprovalStatusRide({
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.driverName,
    required this.rating,
    required this.price,
  });

  final String origin;
  final String destination;
  final String departureTime;
  final String driverName;
  final String rating;
  final String price;

  factory ApprovalStatusRide.fromJson(Map<String, dynamic> j) => ApprovalStatusRide(
        origin: j['origin'] as String? ?? '',
        destination: j['destination'] as String? ?? '',
        departureTime: j['departure_time'] as String? ?? '',
        driverName: j['driver_name'] as String? ?? '',
        rating: j['rating'] as String? ?? '',
        price: j['price'] as String? ?? '',
      );
}

class ApprovalStatusModel {
  const ApprovalStatusModel({
    required this.bookingUuid,
    required this.status,
    required this.reservedSeats,
    required this.totalTimeoutSeconds,
    required this.timeoutAt,
    required this.secondsRemaining,
    required this.ride,
  });

  final String bookingUuid;
  final String status; // 'pending' | 'accepted' | 'rejected' | 'timeout'
  final int reservedSeats;
  final int totalTimeoutSeconds;
  final String timeoutAt;
  final int secondsRemaining;
  final ApprovalStatusRide ride;

  factory ApprovalStatusModel.fromJson(Map<String, dynamic> j) => ApprovalStatusModel(
        bookingUuid: j['booking_uuid'] as String? ?? '',
        status: j['status'] as String? ?? 'pending',
        reservedSeats: j['reserved_seats'] as int? ?? 1,
        totalTimeoutSeconds: j['total_timeout_seconds'] as int? ?? 300,
        timeoutAt: j['timeout_at'] as String? ?? '',
        secondsRemaining: j['seconds_remaining'] as int? ?? 300,
        ride: ApprovalStatusRide.fromJson(j['ride'] as Map<String, dynamic>),
      );
}

// ── Trip Detail ────────────────────────────────────────────────────────────

class TripDetailRide {
  const TripDetailRide({
    required this.uuid,
    required this.driverName,
    required this.driverInitials,
    required this.rating,
    required this.reviewCount,
    required this.vehicle,
    required this.vehiclePlate,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureNote,
    required this.arrivalNote,
    required this.duration,
    required this.price,
    required this.availableSeats,
    this.waypointCity,
    this.waypointNote,
  });

  final String uuid;
  final String driverName;
  final String driverInitials;
  final String rating;
  final int reviewCount;
  final String vehicle;
  final String vehiclePlate;
  final String origin;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final String departureNote;
  final String arrivalNote;
  final String duration;
  final String price;
  final int availableSeats;
  final String? waypointCity;
  final String? waypointNote;

  factory TripDetailRide.fromJson(Map<String, dynamic> j) => TripDetailRide(
        uuid: j['uuid'] as String? ?? '',
        driverName: j['driver_name'] as String? ?? '',
        driverInitials: j['driver_initials'] as String? ?? '',
        rating: j['rating'] as String? ?? '',
        reviewCount: j['review_count'] as int? ?? 0,
        vehicle: j['vehicle'] as String? ?? '',
        vehiclePlate: j['vehicle_plate'] as String? ?? '',
        origin: j['origin'] as String? ?? '',
        destination: j['destination'] as String? ?? '',
        departureTime: j['departure_time'] as String? ?? '',
        arrivalTime: j['arrival_time'] as String? ?? '',
        departureNote: j['departure_note'] as String? ?? '',
        arrivalNote: j['arrival_note'] as String? ?? '',
        duration: j['duration'] as String? ?? '',
        price: j['price'] as String? ?? '',
        availableSeats: j['available_seats'] as int? ?? 0,
        waypointCity: j['waypoint_city'] as String?,
        waypointNote: j['waypoint_note'] as String?,
      );
}

class TripDetailDriverMetrics {
  const TripDetailDriverMetrics({
    required this.acceptanceRate,
    required this.responseTime,
    required this.memberSince,
  });

  final String acceptanceRate;
  final String responseTime;
  final String memberSince;

  factory TripDetailDriverMetrics.fromJson(Map<String, dynamic> j) =>
      TripDetailDriverMetrics(
        acceptanceRate: j['acceptance_rate'] as String? ?? '',
        responseTime: j['response_time'] as String? ?? '',
        memberSince: j['member_since'] as String? ?? '',
      );
}

class TripDetailReview {
  const TripDetailReview({
    required this.reviewerName,
    required this.rating,
    required this.date,
    required this.comment,
  });

  final String reviewerName;
  final double rating;
  final String date;
  final String comment;

  factory TripDetailReview.fromJson(Map<String, dynamic> j) => TripDetailReview(
        reviewerName: j['reviewer_name'] as String? ?? '',
        rating: (j['rating'] as num?)?.toDouble() ?? 0,
        date: j['date'] as String? ?? '',
        comment: j['comment'] as String? ?? '',
      );
}

class TripDetailModel {
  const TripDetailModel({
    required this.ride,
    required this.driverMetrics,
    required this.recentReviews,
    required this.isFavorite,
    required this.isExistingReservation,
    this.reservationUuid,
    this.reservationStatus,
  });

  final TripDetailRide ride;
  final TripDetailDriverMetrics driverMetrics;
  final List<TripDetailReview> recentReviews;
  final bool isFavorite;
  final bool isExistingReservation;
  final String? reservationUuid;
  final String? reservationStatus;

  factory TripDetailModel.fromJson(Map<String, dynamic> j) => TripDetailModel(
        ride: TripDetailRide.fromJson(j['ride'] as Map<String, dynamic>),
        driverMetrics: TripDetailDriverMetrics.fromJson(
            j['driver_metrics'] as Map<String, dynamic>),
        recentReviews: (j['recent_reviews'] as List<dynamic>? ?? [])
            .map((e) => TripDetailReview.fromJson(e as Map<String, dynamic>))
            .toList(),
        isFavorite: j['is_favorite'] as bool? ?? false,
        isExistingReservation: j['is_existing_reservation'] as bool? ?? false,
        reservationUuid: j['reservation_uuid'] as String?,
        reservationStatus: j['reservation_status'] as String?,
      );
}
