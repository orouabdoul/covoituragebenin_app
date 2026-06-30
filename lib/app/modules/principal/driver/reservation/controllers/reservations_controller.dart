import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.65),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(9999))),
            ),
            const SizedBox(height: 20),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(r.passengerInitial,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(r.passengerName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                if (r.isVerified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF4B400), size: 16),
                const SizedBox(width: 4),
                Text('${r.rating}  ·  ${r.tripsCount} trajets',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _PassengerInfoRow(label: 'Trajet', value: r.routeLabel),
                  const SizedBox(height: 8),
                  _PassengerInfoRow(label: 'Départ', value: r.pickupPoint),
                  const SizedBox(height: 8),
                  _PassengerInfoRow(label: 'Arrivée', value: r.dropoffPoint),
                  const SizedBox(height: 8),
                  _PassengerInfoRow(label: 'Places', value: r.seatsLabel),
                  const SizedBox(height: 8),
                  _PassengerInfoRow(label: 'Montant', value: r.amountLabel),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () { Get.back(); onCallPassenger(r); },
              child: Container(
                width: double.infinity, height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.call_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Appeler le passager',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void onCallPassenger(LiveReservationRequest r) {
    const phone = '+229 97 XX XX XX';
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(r.passengerInitial,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(r.passengerName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(phone,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                      color: AppColors.primary, letterSpacing: 1)),
            ),
            const SizedBox(height: 8),
            const Text('Numéro masqué pour votre sécurité',
                style: TextStyle(fontSize: 11, color: AppColors.textGhost)),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: phone));
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Numéro copié.', 0);
            },
            child: const Text('Copier',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
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

class _PassengerInfoRow extends StatelessWidget {
  const _PassengerInfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
