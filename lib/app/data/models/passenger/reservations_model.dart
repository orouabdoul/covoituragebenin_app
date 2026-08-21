// ── Price Breakdown ────────────────────────────────────────────────────────

class PriceBreakdown {
  const PriceBreakdown({
    required this.calculatedPricePerSeat,
    required this.calculatedPricePerSeatFmt,
    required this.seats,
    required this.subtotal,
    required this.subtotalFmt,
    required this.serviceFee,
    required this.serviceFeeFmt,
    required this.serviceFeePct,
    required this.total,
    required this.totalFmt,
    this.driverCommission = 0,
    this.driverCommissionFmt = '',
    this.driverCommissionPct = '',
    this.driverPayout = 0,
    this.driverPayoutFmt = '',
  });

  final int    calculatedPricePerSeat;
  final String calculatedPricePerSeatFmt;
  final int    seats;
  final int    subtotal;
  final String subtotalFmt;
  final int    serviceFee;
  final String serviceFeeFmt;
  final String serviceFeePct;
  final int    total;
  final String totalFmt;
  // Champs internes Minizon (ne pas afficher dans l'UI passager standard)
  final int    driverCommission;
  final String driverCommissionFmt;
  final String driverCommissionPct;
  final int    driverPayout;
  final String driverPayoutFmt;

  factory PriceBreakdown.fromJson(Map<String, dynamic> j) => PriceBreakdown(
        calculatedPricePerSeat:    (j['calculated_price_per_seat'] as num?)?.toInt() ?? 0,
        calculatedPricePerSeatFmt: (j['calculated_price_per_seat_fmt'] ?? '').toString(),
        seats:                     (j['seats'] as num?)?.toInt() ?? 1,
        subtotal:                  (j['subtotal'] as num?)?.toInt() ?? 0,
        subtotalFmt:               (j['subtotal_fmt'] ?? '').toString(),
        serviceFee:                (j['service_fee'] as num?)?.toInt() ?? 0,
        serviceFeeFmt:             (j['service_fee_fmt'] ?? '').toString(),
        serviceFeePct:             (j['service_fee_pct'] ?? '5%').toString(),
        total:                     (j['total'] as num?)?.toInt() ?? 0,
        totalFmt:                  (j['total_fmt'] ?? '').toString(),
        driverCommission:          (j['driver_commission'] as num?)?.toInt() ?? 0,
        driverCommissionFmt:       (j['driver_commission_fmt'] ?? '').toString(),
        driverCommissionPct:       (j['driver_commission_pct'] ?? '').toString(),
        driverPayout:              (j['driver_payout'] as num?)?.toInt() ?? 0,
        driverPayoutFmt:           (j['driver_payout_fmt'] ?? '').toString(),
      );
}

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
        color: (j['color'] as num?)?.toInt() ?? 0xFF7C3AED,
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
        commissionRate: (j['commission_rate'] as num?)?.toInt() ?? 5,
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
    required this.priceSubtotal,
    required this.serviceFee,
    required this.amount,
    required this.status,
    required this.paymentUrl,
    required this.fedapayId,
  });

  final String paymentUuid;
  final String bookingUuid;
  final int priceSubtotal; // sous-total sans frais
  final int serviceFee;    // 5% de frais
  final int amount;        // total débité (priceSubtotal + serviceFee)
  final String status;
  final String paymentUrl;
  final int fedapayId;

  factory PaymentInitResult.fromJson(Map<String, dynamic> j) => PaymentInitResult(
        paymentUuid: (j['payment_uuid'] ?? '').toString(),
        bookingUuid: (j['booking_uuid'] ?? '').toString(),
        priceSubtotal: (j['price_subtotal'] as num?)?.toInt() ?? 0,
        serviceFee: (j['service_fee'] as num?)?.toInt() ?? 0,
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
    required this.calculatedPrice,
    required this.priceSubtotal,
    required this.serviceFee,
    required this.priceTotal,
    required this.passengerDistanceKm,
    required this.tripDistanceKm,
  });

  final String bookingUuid;
  final String bookingMode; // 'approval' | 'instant'
  final int calculatedPrice;  // prix unitaire proraté (par place)
  final int priceSubtotal;    // seats × calculatedPrice
  final int serviceFee;       // 5% du sous-total
  final int priceTotal;       // price_subtotal + service_fee — montant FedaPay
  final double passengerDistanceKm;
  final double tripDistanceKm;

  factory CreateBookingResult.fromJson(Map<String, dynamic> j) =>
      CreateBookingResult(
        bookingUuid: (j['booking_uuid'] ?? '').toString(),
        bookingMode: (j['booking_mode'] ?? 'approval').toString(),
        calculatedPrice: (j['calculated_price'] as num?)?.toInt() ?? 0,
        priceSubtotal: (j['price_subtotal'] as num?)?.toInt() ?? 0,
        serviceFee: (j['service_fee'] as num?)?.toInt() ?? 0,
        priceTotal: (j['price_total'] as num?)?.toInt() ?? 0,
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
    // Nouveaux champs
    this.bookingRef = '',
    this.priceBreakdown,
    this.pickupCity = '',
    this.pickupAddress = '',
    this.dropoffCity = '',
    this.dropoffAddress = '',
    this.passengerDistanceKm,
  });

  final String transactionRef;
  final int amountPaid;
  final String formattedAmount;
  final String driverPhone;
  final String conversationUuid;
  final int reservedSeats;
  final PaymentSuccessRide ride;
  // Nouveaux champs
  final String  bookingRef;
  final PriceBreakdown? priceBreakdown;
  final String  pickupCity;
  final String  pickupAddress;
  final String  dropoffCity;
  final String  dropoffAddress;
  final double? passengerDistanceKm;

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
        // Nouveaux champs
        bookingRef:          (j['booking_ref'] ?? '').toString(),
        priceBreakdown:      j['price_breakdown'] is Map<String, dynamic>
            ? PriceBreakdown.fromJson(j['price_breakdown'] as Map<String, dynamic>)
            : null,
        pickupCity:          (j['pickup_city'] ?? '').toString(),
        pickupAddress:       (j['pickup_address'] ?? '').toString(),
        dropoffCity:         (j['dropoff_city'] ?? '').toString(),
        dropoffAddress:      (j['dropoff_address'] ?? '').toString(),
        passengerDistanceKm: (j['passenger_distance_km'] as num?)?.toDouble(),
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
    // Points passager (prise en charge / dépose)
    required this.departureCity,
    required this.departureNote,
    required this.departureAddress,
    required this.arrivalCity,
    required this.arrivalNote,
    required this.arrivalAddress,
    // Trajet complet du conducteur (contexte)
    required this.tripOrigin,
    required this.tripDestination,
    required this.departureTime,
    required this.departureDate,
    required this.vehicle,
    required this.vehiclePlate,
    this.proratedPrice = 0,
    this.etaMinutes,
    required this.hasRated,
    required this.refundStatus,
    required this.conversationUuid,
    // Nouveaux champs
    this.bookingRef = '',
    this.tripUuid,
    this.paymentRef,
    this.paymentStatus = 'unpaid',
    this.passengerDistanceKm,
    this.departureLat,
    this.departureLng,
    this.arrivalLat,
    this.arrivalLng,
    this.departureDateTime,
    this.priceBreakdown,
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
  // Points passager — ville, quartier, adresse exacte
  final String departureCity;
  final String departureNote;
  final String departureAddress;
  final String arrivalCity;
  final String arrivalNote;
  final String arrivalAddress;
  // Trajet complet conducteur (info contextuelle)
  final String tripOrigin;
  final String tripDestination;
  final int proratedPrice;
  final String departureTime;
  final String departureDate;
  final String vehicle;
  final String vehiclePlate;
  final int? etaMinutes;
  final bool hasRated;
  final String refundStatus;
  final String conversationUuid;
  // Nouveaux champs
  final String  bookingRef;
  final String? tripUuid;
  final String? paymentRef;
  final String  paymentStatus;
  final double? passengerDistanceKm;
  final double? departureLat;
  final double? departureLng;
  final double? arrivalLat;
  final double? arrivalLng;
  final String? departureDateTime;
  final PriceBreakdown? priceBreakdown;

  // Alias pour la compatibilité avec le code existant
  String get pickupCity => departureCity;
  String get dropoffCity => arrivalCity;
  String get pickupNote => departureNote;
  String get dropoffNote => arrivalNote;

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
        departureAddress: (j['departure_address'] ?? '').toString(),
        arrivalCity: (j['arrival_city'] ?? '').toString(),
        arrivalNote: (j['arrival_note'] ?? '').toString(),
        arrivalAddress: (j['arrival_address'] ?? '').toString(),
        tripOrigin: (j['trip_origin'] ?? '').toString(),
        tripDestination: (j['trip_destination'] ?? '').toString(),
        proratedPrice: (j['calculated_price'] as num?)?.toInt() ??
            (j['amount_paid'] as num?)?.toInt() ?? 0,
        departureTime: (j['departure_time'] ?? '').toString(),
        departureDate: (j['departure_date'] ?? '').toString(),
        vehicle: (j['vehicle'] ?? '').toString(),
        vehiclePlate: (j['vehicle_plate'] ?? '').toString(),
        etaMinutes: (j['eta_minutes'] as num?)?.toInt(),
        hasRated: j['has_rated'] as bool? ?? false,
        refundStatus: (j['refund_status'] ?? 'none').toString(),
        conversationUuid: (j['conversation_uuid'] ?? '').toString(),
        // Nouveaux champs
        bookingRef:           (j['booking_ref'] ?? '').toString(),
        tripUuid:             j['trip_uuid']?.toString(),
        paymentRef:           j['payment_ref']?.toString(),
        paymentStatus:        (j['payment_status'] ?? 'unpaid').toString(),
        passengerDistanceKm:  (j['passenger_distance_km'] as num?)?.toDouble(),
        departureLat:         (j['departure_latitude'] as num?)?.toDouble(),
        departureLng:         (j['departure_longitude'] as num?)?.toDouble(),
        arrivalLat:           (j['arrival_latitude'] as num?)?.toDouble(),
        arrivalLng:           (j['arrival_longitude'] as num?)?.toDouble(),
        departureDateTime:    j['departure_datetime']?.toString(),
        priceBreakdown:       j['price_breakdown'] is Map<String, dynamic>
            ? PriceBreakdown.fromJson(j['price_breakdown'] as Map<String, dynamic>)
            : null,
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
    this.priceSubtotal = '',
    this.serviceFee = '',
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
  final String priceSubtotal;
  final String serviceFee;
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
        priceSubtotal: (j['price_subtotal'] ?? '').toString(),
        serviceFee: (j['service_fee'] ?? '').toString(),
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
    // Nouveaux champs
    this.departureDate = '',
    this.pickupCity = '',
    this.pickupNeighborhood = '',
    this.pickupAddress = '',
    this.dropoffCity = '',
    this.dropoffNeighborhood = '',
    this.dropoffAddress = '',
    this.passengerDistanceKm,
    this.priceBreakdown,
  });

  final String origin;
  final String destination;
  final String departureTime;
  final String driverName;
  final String rating;
  final String price;
  // Nouveaux champs
  final String  departureDate;
  final String  pickupCity;
  final String  pickupNeighborhood;
  final String  pickupAddress;
  final String  dropoffCity;
  final String  dropoffNeighborhood;
  final String  dropoffAddress;
  final double? passengerDistanceKm;
  final PriceBreakdown? priceBreakdown;

  factory ApprovalStatusRide.fromJson(Map<String, dynamic> j) =>
      ApprovalStatusRide(
        origin: (j['origin'] ?? '').toString(),
        destination: (j['destination'] ?? '').toString(),
        departureTime: (j['departure_time'] ?? '').toString(),
        driverName: (j['driver_name'] ?? '').toString(),
        rating: (j['rating'] ?? '').toString(),
        price: (j['price'] ?? '').toString(),
        // Nouveaux champs
        departureDate:       (j['departure_date'] ?? '').toString(),
        pickupCity:          (j['pickup_city'] ?? '').toString(),
        pickupNeighborhood:  (j['pickup_neighborhood'] ?? '').toString(),
        pickupAddress:       (j['pickup_address'] ?? '').toString(),
        dropoffCity:         (j['dropoff_city'] ?? '').toString(),
        dropoffNeighborhood: (j['dropoff_neighborhood'] ?? '').toString(),
        dropoffAddress:      (j['dropoff_address'] ?? '').toString(),
        passengerDistanceKm: (j['passenger_distance_km'] as num?)?.toDouble(),
        priceBreakdown:      j['price_breakdown'] is Map<String, dynamic>
            ? PriceBreakdown.fromJson(j['price_breakdown'] as Map<String, dynamic>)
            : null,
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

  factory TripDetailModel.fromJson(Map<String, dynamic> j) {
    // driver_metrics peut être imbriqué sous 'driver_metrics', au niveau racine,
    // ou encore à l'intérieur de 'ride'. On fusionne les trois sources.
    final nested  = j['driver_metrics'] is Map<String, dynamic>
        ? j['driver_metrics'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final rideMap = j['ride'] is Map<String, dynamic>
        ? j['ride'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final metricsJson = <String, dynamic>{
      'acceptance_rate': nested['acceptance_rate']
          ?? j['acceptance_rate']
          ?? rideMap['acceptance_rate'],
      'response_time':   nested['response_time']
          ?? j['response_time']
          ?? rideMap['response_time'],
      'member_since':    nested['member_since']
          ?? j['member_since']
          ?? rideMap['member_since'],
    };
    return TripDetailModel(
        ride: TripDetailRide.fromJson(rideMap),
        driverMetrics: TripDetailDriverMetrics.fromJson(metricsJson),
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
}
