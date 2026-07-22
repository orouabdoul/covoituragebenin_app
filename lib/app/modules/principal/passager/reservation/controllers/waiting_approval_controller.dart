import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
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

  String _bookingUuid = '';
  Timer? _pollingTimer;

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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (savedArgs is Map<String, dynamic>) {
        final r = savedArgs['ride'];
        if (r is SearchRide) ride.value = r;
        final seats = savedArgs['seats'];
        if (seats is int) reservedSeats.value = seats;
        final idx = savedArgs['paymentIndex'];
        if (idx is int) paymentIndex.value = idx;
        final uuid = savedArgs['bookingUuid'];
        if (uuid is String && uuid.isNotEmpty) {
          _bookingUuid = uuid;
          _startPolling();
          return;
        }
      }
      // UUID manquant — on ne peut pas attendre la confirmation d'un conducteur sans référence
      UIHelper().showSnackBar(
        'MINIZON',
        'Réservation introuvable. Vérifiez dans Mes Réservations.',
        3,
      );
      Get.back();
    });
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
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
      return;
    }
    final data = result.data!;
    secondsRemaining.value = data.secondsRemaining;
    totalTimeoutSeconds.value = data.totalTimeoutSeconds;

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
      'amount': '2 500 FCFA',
      'route': '${ride.value?.origin ?? 'Départ'} → ${ride.value?.destination ?? 'Arrivée'}',
      'date': DateTime.now().toString().substring(0, 10),
      'ref': 'REF-${DateTime.now().millisecondsSinceEpoch}',
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
