import 'dart:async';

import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/app_sync.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reservations_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import '../../search/controllers/search_controller.dart';

enum WaitingStatus { pending, accepted, rejected, timeout }

class WaitingApprovalController extends GetxController {
  PassengerReservationService get _service =>
      Get.find<PassengerReservationService>();

  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final status = WaitingStatus.pending.obs;
  final secondsRemaining = 300.obs;
  final RxInt totalTimeoutSeconds = 300.obs;
  final RxInt reservedSeats = 1.obs;
  final RxInt paymentIndex = 0.obs;
  final pickupCity = ''.obs;
  final pickupAddress = ''.obs;
  final dropoffCity = ''.obs;
  final dropoffAddress = ''.obs;
  final Rxn<PriceBreakdown> priceBreakdown = Rxn<PriceBreakdown>();
  final Rxn<double> passengerDistanceKm = Rxn<double>();

  String _bookingUuid = '';
  int _totalAmount = 0;
  Timer? _pollingTimer;
  int _consecutiveErrors = 0;

  String get timeLabel {
    final m = secondsRemaining.value ~/ 60;
    final s = secondsRemaining.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get progressFraction =>
      secondsRemaining.value / totalTimeoutSeconds.value.clamp(1, 999999);

  @override
  void onInit() {
    super.onInit();
    final dynamic savedArgs = Get.arguments;
    if (savedArgs is Map<String, dynamic>) {
      final r = savedArgs['ride'];
      if (r is SearchRide) ride.value = r;
      final seats = savedArgs['seats'];
      if (seats is int) reservedSeats.value = seats;
      final idx = savedArgs['paymentIndex'];
      if (idx is int) paymentIndex.value = idx;
      final amt = savedArgs['totalAmount'];
      if (amt is int && amt > 0) _totalAmount = amt;
      // Supporte 'bookingUuid' (flow normal) et 'bookingUuid' via notification push
      final rawUuid = savedArgs['bookingUuid'] ?? savedArgs['booking_uuid'];
      final uuid = rawUuid is String ? rawUuid : null;
      if (uuid != null && uuid.isNotEmpty) {
        _bookingUuid = uuid;
        _startPolling();
        return;
      }
    }
    UIHelper().showSnackBar(
      'MINIZON',
      'Réservation en cours de synchronisation…',
      2,
    );
  }

  // ── API polling ────────────────────────────────────────────────────────────

  void _startPolling() {
    _pollOnce();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (status.value != WaitingStatus.pending) return;
    final result = await _service.fetchApprovalStatus(_bookingUuid);
    if (!result.isSuccess) {
      _consecutiveErrors++;
      if (_consecutiveErrors == 3 && result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
      return;
    }
    _consecutiveErrors = 0;
    final data = result.data!;
    secondsRemaining.value = data.secondsRemaining;
    totalTimeoutSeconds.value = data.totalTimeoutSeconds;
    if (data.reservedSeats > 0) reservedSeats.value = data.reservedSeats;

    final approvalRide = data.ride;
    if (approvalRide.pickupCity.isNotEmpty) pickupCity.value = approvalRide.pickupCity;
    if (approvalRide.pickupAddress.isNotEmpty) pickupAddress.value = approvalRide.pickupAddress;
    if (approvalRide.dropoffCity.isNotEmpty) dropoffCity.value = approvalRide.dropoffCity;
    if (approvalRide.dropoffAddress.isNotEmpty) dropoffAddress.value = approvalRide.dropoffAddress;
    if (approvalRide.priceBreakdown != null) priceBreakdown.value = approvalRide.priceBreakdown;
    passengerDistanceKm.value = approvalRide.passengerDistanceKm;

    // Reconstruit le SearchRide depuis les données de polling si absent (ouverture via notification)
    if (ride.value == null && approvalRide.driverName.isNotEmpty) {
      final bd = approvalRide.priceBreakdown;
      final priceInt = bd != null && bd.total > 0
          ? bd.total
          : int.tryParse(approvalRide.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      ride.value = SearchRide(
        driverName: approvalRide.driverName,
        driverInitials: _initials(approvalRide.driverName),
        rating: approvalRide.rating,
        reviewCount: '',
        vehicle: '',
        vehiclePlate: '',
        price: approvalRide.price.isNotEmpty ? approvalRide.price : (bd?.totalFmt ?? ''),
        priceValue: priceInt,
        origin: approvalRide.origin,
        destination: approvalRide.destination,
        departureTime: approvalRide.departureTime,
        departureNote: approvalRide.pickupCity,
        arrivalTime: '',
        arrivalNote: approvalRide.dropoffCity,
        duration: '',
        seatsAvailable: data.reservedSeats,
        minutesUntilDeparture: data.secondsRemaining ~/ 60,
        isVerified: false,
      );
    }

    // Met à jour le montant total depuis le pricing si pas encore connu
    if (_totalAmount == 0) {
      final bd = approvalRide.priceBreakdown;
      if (bd != null && bd.total > 0) {
        _totalAmount = bd.total;
      } else {
        final parsed = int.tryParse(approvalRide.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        if (parsed > 0) _totalAmount = parsed;
      }
    }

    switch (data.status) {
      case 'accepted':
        _cancelTimers();
        _onAccepted();
      case 'rejected':
        _cancelTimers();
        status.value = WaitingStatus.rejected;
      case 'timeout':
        _cancelTimers();
        status.value = WaitingStatus.timeout;
      default:
        break;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  // ── Status transitions ─────────────────────────────────────────────────────

  void _onAccepted() {
    _cancelTimers();
    status.value = WaitingStatus.accepted;
    AppSync.i.refreshPassenger();
    Future.delayed(const Duration(milliseconds: 1400), () {
      Get.toNamed(
        AppRoutes.passengerReservationPayment,
        arguments: {
          'ride': ride.value,
          'seats': reservedSeats.value,
          'paymentIndex': paymentIndex.value,
          'bookingUuid': _bookingUuid,
          'totalAmount': _totalAmount,
        },
      );
    });
  }

  void cancelRequest() {
    _cancelTimers();
    Get.back();
  }

  void retrySearch() {
    _cancelTimers();
    BottonNavController.goToTab(1);
  }

  void searchAnother() {
    _cancelTimers();
    BottonNavController.goToTab(1);
  }

  void requestRefund() {
    _cancelTimers();
    Get.toNamed(AppRoutes.passengerRefundRequest, arguments: {
      'bookingUuid': _bookingUuid,
      'route': '${ride.value?.origin ?? 'Départ'} → ${ride.value?.destination ?? 'Arrivée'}',
    });
  }

  void _cancelTimers() {
    _pollingTimer?.cancel();
  }

  @override
  void onClose() {
    _cancelTimers();
    super.onClose();
  }
}
