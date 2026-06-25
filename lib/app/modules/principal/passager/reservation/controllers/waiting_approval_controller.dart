import 'dart:async';

import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import '../../search/controllers/search_controller.dart';

enum WaitingStatus { pending, accepted, rejected, timeout }

class WaitingApprovalController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final status = WaitingStatus.pending.obs;
  final secondsRemaining = 300.obs;
  final RxInt reservedSeats = 1.obs;
  final RxInt paymentIndex = 0.obs;

  Timer? _countdownTimer;
  Timer? _simulationTimer;

  String get timeLabel {
    final m = secondsRemaining.value ~/ 60;
    final s = secondsRemaining.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get progressFraction => secondsRemaining.value / 300.0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final r = args['ride'];
      if (r is SearchRide) ride.value = r;
      final seats = args['seats'];
      if (seats is int) reservedSeats.value = seats;
      final idx = args['paymentIndex'];
      if (idx is int) paymentIndex.value = idx;
    }
    _startCountdown();
    _simulateAcceptance();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        _onTimeout();
      }
    });
  }

  void _simulateAcceptance() {
    _simulationTimer = Timer(const Duration(seconds: 4), () {
      if (status.value == WaitingStatus.pending) {
        _onAccepted();
      }
    });
  }

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
        },
      );
    });
  }

  void _onTimeout() {
    _cancelTimers();
    status.value = WaitingStatus.timeout;
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
    _countdownTimer?.cancel();
    _simulationTimer?.cancel();
  }

  @override
  void onClose() {
    _cancelTimers();
    super.onClose();
  }
}
