import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

enum ReservationStatus { pending, accepted, rejected, expired }
enum ReservationUrgency { normal, warning, critical }

class LiveReservationRequest {
  LiveReservationRequest({
    required this.id,
    required this.passengerName,
    required this.passengerInitial,
    required this.rating,
    required this.tripsCount,
    required this.isVerified,
    required this.routeLabel,
    required this.pickupPoint,
    required this.dropoffPoint,
    required this.seats,
    required this.amount,
    required this.paymentConfirmed,
    required this.expiresInSeconds,
    this.status = ReservationStatus.pending,
  }) : remainingSeconds = expiresInSeconds.obs;

  final String id;
  final String passengerName;
  final String passengerInitial;
  final double rating;
  final int tripsCount;
  final bool isVerified;
  final String routeLabel;
  final String pickupPoint;
  final String dropoffPoint;
  final int seats;
  final double amount;
  final bool paymentConfirmed;
  final int expiresInSeconds;
  ReservationStatus status;

  final RxInt remainingSeconds;
  Timer? _timer;

  String get amountLabel =>
      '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';

  String get seatsLabel => seats == 1 ? '1 place' : '$seats places';

  Color get urgencyColor {
    final secs = remainingSeconds.value;
    if (secs <= 60) return const Color(0xFFE53935);
    if (secs <= 120) return const Color(0xFFF59E0B);
    return AppColors.primary;
  }

  ReservationUrgency get urgency {
    final secs = remainingSeconds.value;
    if (secs <= 60) return ReservationUrgency.critical;
    if (secs <= 120) return ReservationUrgency.warning;
    return ReservationUrgency.normal;
  }

  String get countdownLabel {
    final secs = remainingSeconds.value;
    if (secs <= 0) return 'Expirée';
    final m = secs ~/ 60;
    final s = secs % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  void startTimer(VoidCallback onExpire) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        onExpire();
      }
    });
  }

  void cancelTimer() => _timer?.cancel();

  Color get borderColor {
    return switch (urgency) {
      ReservationUrgency.critical => const Color(0xFFE53935),
      ReservationUrgency.warning => const Color(0xFFF59E0B),
      ReservationUrgency.normal => AppColors.border,
    };
  }
}

enum ReservationTab { pending, accepted, rejected }

class ReservationsController extends GetxController {
  final Rx<ReservationTab> selectedTab = ReservationTab.pending.obs;
  final RxBool isLoading = false.obs;

  final RxList<LiveReservationRequest> pendingRequests = <LiveReservationRequest>[
    LiveReservationRequest(
      id: 'r1',
      passengerName: 'Aminata Koné',
      passengerInitial: 'A',
      rating: 4.9,
      tripsCount: 127,
      isVerified: true,
      routeLabel: 'Cotonou → Porto-Novo',
      pickupPoint: 'Carrefour Tokpa, devant Ecobank',
      dropoffPoint: 'Université Abomey-Calavi',
      seats: 2,
      amount: 5000,
      paymentConfirmed: true,
      expiresInSeconds: 272,
    ),
    LiveReservationRequest(
      id: 'r2',
      passengerName: 'Kwame Asante',
      passengerInitial: 'K',
      rating: 4.7,
      tripsCount: 89,
      isVerified: true,
      routeLabel: 'Cotonou → Porto-Novo',
      pickupPoint: 'Akpakpa, Carrefour Fiat',
      dropoffPoint: 'Centre Porto-Novo',
      seats: 1,
      amount: 2500,
      paymentConfirmed: true,
      expiresInSeconds: 78,
    ),
    LiveReservationRequest(
      id: 'r3',
      passengerName: 'Fatou Diallo',
      passengerInitial: 'F',
      rating: 5.0,
      tripsCount: 45,
      isVerified: true,
      routeLabel: 'Calavi → Bohicon',
      pickupPoint: 'Carrefour Godomey',
      dropoffPoint: 'Bohicon Centre',
      seats: 3,
      amount: 7500,
      paymentConfirmed: false,
      expiresInSeconds: 1390,
    ),
  ].obs;

  final RxList<LiveReservationRequest> acceptedRequests = <LiveReservationRequest>[
    LiveReservationRequest(
      id: 'r4',
      passengerName: 'Mariam Yessoufou',
      passengerInitial: 'M',
      rating: 4.8,
      tripsCount: 62,
      isVerified: true,
      routeLabel: 'Cotonou → Abomey',
      pickupPoint: 'Ganhi',
      dropoffPoint: 'Abomey Centre',
      seats: 2,
      amount: 5500,
      paymentConfirmed: true,
      expiresInSeconds: 0,
      status: ReservationStatus.accepted,
    ),
  ].obs;

  final RxList<LiveReservationRequest> rejectedRequests = <LiveReservationRequest>[].obs;

  int get pendingCount => pendingRequests.length;
  int get acceptedCount => acceptedRequests.length;
  int get rejectedCount => rejectedRequests.length;

  @override
  void onInit() {
    super.onInit();
    _startAllTimers();
  }

  void _startAllTimers() {
    for (final r in pendingRequests) {
      r.startTimer(() => _onExpired(r));
    }
  }

  void _onExpired(LiveReservationRequest r) {
    r.status = ReservationStatus.expired;
    pendingRequests.remove(r);
    rejectedRequests.insert(0, r);
    UIHelper().showSnackBar(
      'MINIZON',
      'Demande de ${r.passengerName} expirée automatiquement.',
      1,
    );
  }

  void onAccept(LiveReservationRequest r) {
    r.cancelTimer();
    r.status = ReservationStatus.accepted;
    pendingRequests.remove(r);
    acceptedRequests.insert(0, r);
    UIHelper().showSnackBar(
      'MINIZON',
      '✅ Réservation de ${r.passengerName} acceptée !',
      0,
    );
  }

  void onReject(LiveReservationRequest r) {
    _showRejectDialog(r);
  }

  void _showRejectDialog(LiveReservationRequest r) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Refuser la demande ?',
            style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: Text(
          'La demande de ${r.passengerName} sera annulée et le passager sera notifié.',
          style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _confirmReject(r);
            },
            child: const Text('Refuser',
                style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmReject(LiveReservationRequest r) {
    r.cancelTimer();
    r.status = ReservationStatus.rejected;
    pendingRequests.remove(r);
    rejectedRequests.insert(0, r);
    UIHelper().showSnackBar('MINIZON', 'Demande de ${r.passengerName} refusée.', 2);
  }

  void onViewPassenger(LiveReservationRequest r) {
    UIHelper().showSnackBar('MINIZON', 'Profil de ${r.passengerName} bientôt disponible.', 1);
  }

  void onCallPassenger(LiveReservationRequest r) {
    UIHelper().showSnackBar('MINIZON', 'Appel vers ${r.passengerName}…', 1);
  }

  void onNotifications() => Get.toNamed(AppRoutes.driverNotifications);

  void onBack() => Get.back();

  @override
  void onClose() {
    for (final r in pendingRequests) {
      r.cancelTimer();
    }
    super.onClose();
  }
}
