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
        uuid: (j['uuid'] ?? '').toString(),
        availableSeats: (j['available_seats'] as num?)?.toInt() ?? 0,
        maxPerBooking: (j['max_per_booking'] as num?)?.toInt() ?? 0,
        pricePerSeat: (j['price_per_seat'] as num?)?.toInt() ?? 0,
        bookingMode: (j['booking_mode'] ?? 'approval').toString(),
        distanceKm: (j['distance_km'] ?? '').toString(),
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
        provider: (j['provider'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        iconName: (j['icon'] ?? 'phone_android').toString(),
        color: (j['color'] as num?)?.toInt() ?? 0xFF00A86B,
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
        trip: ConfirmationContextTripInfo.fromJson(
            j['trip'] is Map<String, dynamic>
                ? j['trip'] as Map<String, dynamic>
                : const {}),
        commissionRate: (j['commission_rate'] as num?)?.toInt() ?? 10,
        userPhone: (j['user_phone'] ?? '').toString(),
        paymentMethods: (j['payment_methods'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((e) => ApiPaymentMethod.fromJson(e))
            .toList(),
      );
}

// ── Payment Init Result ────────────────────────────────────────────────────

class PaymentInitResult {
  const PaymentInitResult({
    required this.paymentUuid,
    required this.bookingUuid,
    required this.amount,
    required this.status,
    required this.paymentUrl,
    required this.fedapayId,
  });

  final String paymentUuid;
  final String bookingUuid;
  final int amount;
  final String status;
  final String paymentUrl;
  final int fedapayId;

  factory PaymentInitResult.fromJson(Map<String, dynamic> j) => PaymentInitResult(
        paymentUuid: (j['payment_uuid'] ?? '').toString(),
        bookingUuid: (j['booking_uuid'] ?? '').toString(),
        amount: (j['amount'] as num?)?.toInt() ?? 0,
        status: (j['status'] ?? 'pending').toString(),
        paymentUrl: (j['payment_url'] ?? '').toString(),
        fedapayId: (j['fedapay_id'] as num?)?.toInt() ?? 0,
      );
}

// ── Create Booking Result ──────────────────────────────────────────────────

class CreateBookingResult {
  const CreateBookingResult({
    required this.bookingUuid,
    required this.bookingMode,
    required this.priceTotal,
    required this.calculatedPrice,
    required this.passengerDistanceKm,
    required this.tripDistanceKm,
  });

  final String bookingUuid;
  final String bookingMode; // 'approval' | 'instant'
  final int priceTotal;
  final int calculatedPrice;
  final double passengerDistanceKm;
  final double tripDistanceKm;

  factory CreateBookingResult.fromJson(Map<String, dynamic> j) =>
      CreateBookingResult(
        bookingUuid: (j['booking_uuid'] ?? '').toString(),
        bookingMode: (j['booking_mode'] ?? 'approval').toString(),
        priceTotal: (j['price_total'] as num?)?.toInt() ?? 0,
        calculatedPrice: (j['calculated_price'] as num?)?.toInt() ?? 0,
        passengerDistanceKm:
            (j['passenger_distance_km'] as num?)?.toDouble() ?? 0.0,
        tripDistanceKm: (j['trip_distance_km'] as num?)?.toDouble() ?? 0.0,
      );

  String get formattedCalculatedPrice {
    final s = calculatedPrice
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
    return '$s FCFA';
  }

  String get formattedPassengerDistance =>
      '${passengerDistanceKm.toStringAsFixed(1)} km';

  String get formattedTripDistance =>
      '${tripDistanceKm.toStringAsFixed(1)} km';
}

// ── Payment Status (polling step 4) ───────────────────────────────────────

class PaymentStatusModel {
  const PaymentStatusModel({
    required this.paymentUuid,
    required this.status,
    required this.grossAmount,
    required this.provider,
    required this.transactionRef,
    required this.bookingUuid,
  });

  final String paymentUuid;
  final String status; // 'pending' | 'locked' | 'success' | 'failed'
  final int grossAmount;
  final String provider;
  final String transactionRef;
  final String bookingUuid;

  factory PaymentStatusModel.fromJson(Map<String, dynamic> j) =>
      PaymentStatusModel(
        paymentUuid: (j['payment_uuid'] ?? '').toString(),
        status: (j['status'] ?? 'pending').toString(),
        grossAmount: (j['gross_amount'] as num?)?.toInt() ?? 0,
        provider: (j['provider'] ?? '').toString(),
        transactionRef: (j['transaction_ref'] ?? '').toString(),
        bookingUuid: (j['booking_uuid'] ?? '').toString(),
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
        driverName: (j['driver_name'] ?? '').toString(),
        driverInitials: (j['driver_initials'] ?? '').toString(),
        rating: (j['rating'] ?? '').toString(),
        vehicle: (j['vehicle'] ?? '').toString(),
        vehiclePlate: (j['vehicle_plate'] ?? '').toString(),
        driverPhone: (j['driver_phone'] ?? '').toString(),
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
        speedKmh: (j['speed_kmh'] as num?)?.toInt() ?? 0,
        etaMinutes: (j['eta_minutes'] as num?)?.toInt() ?? 0,
        distanceRemainingKm:
            (j['distance_remaining_km'] as num?)?.toDouble() ?? 0,
        tripStatus: (j['trip_status'] ?? 'active').toString(),
        tripEnded: j['trip_ended'] as bool? ?? false,
        ride: LiveTrackingRideInfo.fromJson(
            j['ride'] is Map<String, dynamic>
                ? j['ride'] as Map<String, dynamic>
                : const {}),
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

  factory PaymentSuccessRide.fromJson(Map<String, dynamic> j) =>
      PaymentSuccessRide(
        uuid: (j['uuid'] ?? '').toString(),
        driverName: (j['driver_name'] ?? '').toString(),
        driverInitials: (j['driver_initials'] ?? '').toString(),
        rating: (j['rating'] ?? '').toString(),
        reviewCount: (j['review_count'] as num?)?.toInt() ?? 0,
        vehicle: (j['vehicle'] ?? '').toString(),
        vehiclePlate: (j['vehicle_plate'] ?? '').toString(),
        origin: (j['origin'] ?? '').toString(),
        destination: (j['destination'] ?? '').toString(),
        departureTime: (j['departure_time'] ?? '').toString(),
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

  factory PaymentSuccessModel.fromJson(Map<String, dynamic> j) =>
      PaymentSuccessModel(
        transactionRef: (j['transaction_ref'] ?? '').toString(),
        amountPaid: (j['amount_paid'] as num?)?.toInt() ?? 0,
        formattedAmount: (j['formatted_amount'] ?? '').toString(),
        driverPhone: (j['driver_phone'] ?? '').toString(),
        conversationUuid: (j['conversation_uuid'] ?? '').toString(),
        reservedSeats: (j['reserved_seats'] as num?)?.toInt() ?? 1,
        ride: PaymentSuccessRide.fromJson(
            j['ride'] is Map<String, dynamic>
                ? j['ride'] as Map<String, dynamic>
                : const {}),
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
        uuid: (j['uuid'] ?? '').toString(),
        departureCity: (j['departure_city'] ?? '').toString(),
        arrivalCity: (j['arrival_city'] ?? '').toString(),
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
        status: (j['status'] ?? '').toString(),
        label: (j['label'] ?? '').toString(),
        count: (j['count'] as num?)?.toInt() ?? 0,
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
    required this.conversationUuid,
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
  final String conversationUuid;

  factory ReservationApiItem.fromJson(Map<String, dynamic> j) =>
      ReservationApiItem(
        uuid: (j['uuid'] ?? '').toString(),
        status: (j['status'] ?? 'pending').toString(),
        isPaid: j['is_paid'] as bool? ?? false,
        cancelReason: j['cancel_reason']?.toString(),
        timeAgo: (j['time_ago'] ?? '').toString(),
        driverName: (j['driver_name'] ?? '').toString(),
        driverInitials: (j['driver_initials'] ?? '').toString(),
        rating: (j['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (j['review_count'] ?? '').toString(),
        totalPrice: (j['total_price'] ?? '').toString(),
        seatsCount: (j['seats_count'] as num?)?.toInt() ?? 1,
        departureCity: (j['departure_city'] ?? '').toString(),
        departureNote: (j['departure_note'] ?? '').toString(),
        arrivalCity: (j['arrival_city'] ?? '').toString(),
        arrivalNote: (j['arrival_note'] ?? '').toString(),
        departureTime: (j['departure_time'] ?? '').toString(),
        departureDate: (j['departure_date'] ?? '').toString(),
        vehicle: (j['vehicle'] ?? '').toString(),
        vehiclePlate: (j['vehicle_plate'] ?? '').toString(),
        etaMinutes: (j['eta_minutes'] as num?)?.toInt(),
        hasRated: j['has_rated'] as bool? ?? false,
        refundStatus: (j['refund_status'] ?? 'none').toString(),
        conversationUuid: (j['conversation_uuid'] ?? '').toString(),
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

  factory ReservationsPageModel.fromJson(Map<String, dynamic> j) =>
      ReservationsPageModel(
        activeTrip: j['active_trip'] is Map<String, dynamic>
            ? ActiveTripBanner.fromJson(j['active_trip'] as Map<String, dynamic>)
            : null,
        statusTabs: (j['status_tabs'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((e) => ReservationStatusTabApi.fromJson(e))
            .toList(),
        items: (j['items'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((e) => ReservationApiItem.fromJson(e))
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
        invoiceRef: (j['invoice_ref'] ?? '').toString(),
        issuedAt: (j['issued_at'] ?? '').toString(),
        passengerName: (j['passenger_name'] ?? '').toString(),
        driverName: (j['driver_name'] ?? '').toString(),
        route: (j['route'] ?? '').toString(),
        departureDate: (j['departure_date'] ?? '').toString(),
        seats: (j['seats'] as num?)?.toInt() ?? 1,
        pricePerSeat: (j['price_per_seat'] ?? '').toString(),
        totalAmount: (j['total_amount'] ?? '').toString(),
        paymentMethod: (j['payment_method'] ?? '').toString(),
        transactionRef: (j['transaction_ref'] ?? '').toString(),
        bookingRef: (j['booking_ref'] ?? '').toString(),
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

  factory TripConfirmationRide.fromJson(Map<String, dynamic> j) =>
      TripConfirmationRide(
        origin: (j['origin'] ?? '').toString(),
        destination: (j['destination'] ?? '').toString(),
        duration: (j['duration'] ?? '').toString(),
        driverName: (j['driver_name'] ?? '').toString(),
        driverInitials: (j['driver_initials'] ?? '').toString(),
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
        ride: TripConfirmationRide.fromJson(
            j['ride'] is Map<String, dynamic>
                ? j['ride'] as Map<String, dynamic>
                : const {}),
        alreadyReviewed: j['already_reviewed'] as bool? ?? false,
        passengerConfirmedAt: j['passenger_confirmed_at']?.toString(),
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

  factory ApprovalStatusRide.fromJson(Map<String, dynamic> j) =>
      ApprovalStatusRide(
        origin: (j['origin'] ?? '').toString(),
        destination: (j['destination'] ?? '').toString(),
        departureTime: (j['departure_time'] ?? '').toString(),
        driverName: (j['driver_name'] ?? '').toString(),
        rating: (j['rating'] ?? '').toString(),
        price: (j['price'] ?? '').toString(),
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

  factory ApprovalStatusModel.fromJson(Map<String, dynamic> j) =>
      ApprovalStatusModel(
        bookingUuid: (j['booking_uuid'] ?? '').toString(),
        status: (j['status'] ?? 'pending').toString(),
        reservedSeats: (j['reserved_seats'] as num?)?.toInt() ?? 1,
        totalTimeoutSeconds: (j['total_timeout_seconds'] as num?)?.toInt() ?? 300,
        timeoutAt: (j['timeout_at'] ?? '').toString(),
        secondsRemaining: (j['seconds_remaining'] as num?)?.toInt() ?? 300,
        ride: ApprovalStatusRide.fromJson(
            j['ride'] is Map<String, dynamic>
                ? j['ride'] as Map<String, dynamic>
                : const {}),
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
        uuid: (j['uuid'] ?? '').toString(),
        driverName: (j['driver_name'] ?? '').toString(),
        driverInitials: (j['driver_initials'] ?? '').toString(),
        rating: (j['rating'] ?? '').toString(),
        reviewCount: (j['review_count'] as num?)?.toInt() ?? 0,
        vehicle: (j['vehicle'] ?? '').toString(),
        vehiclePlate: (j['vehicle_plate'] ?? '').toString(),
        origin: (j['origin'] ?? '').toString(),
        destination: (j['destination'] ?? '').toString(),
        departureTime: (j['departure_time'] ?? '').toString(),
        arrivalTime: (j['arrival_time'] ?? '').toString(),
        departureNote: (j['departure_note'] ?? '').toString(),
        arrivalNote: (j['arrival_note'] ?? '').toString(),
        duration: (j['duration'] ?? '').toString(),
        price: (j['price'] ?? '').toString(),
        availableSeats: (j['available_seats'] as num?)?.toInt() ?? 0,
        waypointCity: j['waypoint_city']?.toString(),
        waypointNote: j['waypoint_note']?.toString(),
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
        acceptanceRate: (j['acceptance_rate'] ?? '').toString(),
        responseTime: (j['response_time'] ?? '').toString(),
        memberSince: (j['member_since'] ?? '').toString(),
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
        reviewerName: (j['reviewer_name'] ?? '').toString(),
        rating: (j['rating'] as num?)?.toDouble() ?? 0,
        date: (j['date'] ?? '').toString(),
        comment: (j['comment'] ?? '').toString(),
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
        ride: TripDetailRide.fromJson(
            j['ride'] is Map<String, dynamic>
                ? j['ride'] as Map<String, dynamic>
                : const {}),
        driverMetrics: TripDetailDriverMetrics.fromJson(
            j['driver_metrics'] is Map<String, dynamic>
                ? j['driver_metrics'] as Map<String, dynamic>
                : const {}),
        recentReviews: (j['recent_reviews'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((e) => TripDetailReview.fromJson(e))
            .toList(),
        isFavorite: j['is_favorite'] as bool? ?? false,
        isExistingReservation: j['is_existing_reservation'] as bool? ?? false,
        reservationUuid: j['reservation_uuid']?.toString(),
        reservationStatus: j['reservation_status']?.toString(),
      );
}
