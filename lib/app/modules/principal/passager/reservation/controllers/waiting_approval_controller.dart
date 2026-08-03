import 'dart:async';

import 'package:get/get.dart';

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
      final uuid = savedArgs['bookingUuid'];
      if (uuid is String && uuid.isNotEmpty) {
        _bookingUuid = uuid;
        _startPolling();
        return;
      }
    }
    // UUID manquant — démarrer le polling sans UUID (mode dégradé)
    // On ne redirige pas pour ne pas quitter la page d'attente
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
      // Afficher un message seulement après 3 erreurs consécutives (réseau instable)
      if (_consecutiveErrors == 3 && result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
      return;
    }
    _consecutiveErrors = 0;
    final data = result.data!;
    secondsRemaining.value = data.secondsRemaining;
    totalTimeoutSeconds.value = data.totalTimeoutSeconds;
    if (data.pickupCity.isNotEmpty) pickupCity.value = data.pickupCity;
    if (data.pickupAddress.isNotEmpty) pickupAddress.value = data.pickupAddress;
    if (data.dropoffCity.isNotEmpty) dropoffCity.value = data.dropoffCity;
    if (data.dropoffAddress.isNotEmpty) dropoffAddress.value = data.dropoffAddress;
    if (data.priceBreakdown != null) priceBreakdown.value = data.priceBreakdown;
    passengerDistanceKm.value = data.passengerDistanceKm;

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

  // ── Status transitions ─────────────────────────────────────────────────────

  void _onAccepted() {
    _cancelTimers();
    status.value = WaitingStatus.accepted;
    Future.delayed(const Duration(milliseconds: 1400), () {
      Get.toNamed(
        AppRoutes.passengerReservationPayment,
        arguments: {
          'ride': ride.value,
          'seats': reservedSeats.value,
          'paymentIndex': paymentIndex.value,
          if (_bookingUuid.isNotEmpty) 'bookingUuid': _bookingUuid,
          if (_totalAmount > 0) 'totalAmount': _totalAmount,
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
