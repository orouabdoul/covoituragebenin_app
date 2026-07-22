import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/booking/booking_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

enum ReservationStatus { pending, accepted, rejected, expired }
enum ReservationUrgency { normal, warning, critical }
enum ReservationTab { pending, accepted, rejected }

// ── Model ────────────────────────────────────────────────────────────────────

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
    this.phone,
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
  final String? phone;
  ReservationStatus status;

  final RxInt remainingSeconds;
  Timer? _timer;

  factory LiveReservationRequest.fromJson(Map<String, dynamic> json) {
    final trip = json['trip'] as Map<String, dynamic>? ?? {};
    final passenger = json['passenger'] as Map<String, dynamic>? ?? {};
    final profile = passenger['profile'] as Map<String, dynamic>? ?? {};

    final firstName = profile['first_name'] as String? ?? '';
    final lastName = profile['last_name'] as String? ?? '';
    final name = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : passenger['phone'] as String? ?? 'Passager';

    final departureCity = (trip['departure_city'] as String?)?.isNotEmpty == true
        ? trip['departure_city'] as String
        : (trip['origin'] as String?) ?? '';
    final arrivalCity = (trip['arrival_city'] as String?)?.isNotEmpty == true
        ? trip['arrival_city'] as String
        : (trip['destination'] as String?) ?? '';

    final pickupPoint = _resolvePoint(
      trip['departure_point'] as String? ?? trip['origin_point'] as String?,
      trip['departure_neighborhood'] as String?,
      departureCity,
    );
    final dropoffPoint = _resolvePoint(
      trip['arrival_point'] as String? ?? trip['destination_point'] as String?,
      trip['arrival_neighborhood'] as String?,
      arrivalCity,
    );

    final seats = (json['seats_booked'] as num?)?.toInt() ?? 1;
    final pricePerSeat = (trip['price_per_seat'] as num?)?.toDouble() ?? 0.0;

    // 15-minute window from creation time
    const windowSec = 15 * 60;
    var expiresIn = windowSec;
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      try {
        final elapsed = DateTime.now()
            .difference(DateTime.parse(createdAtStr).toLocal())
            .inSeconds;
        expiresIn = (windowSec - elapsed).clamp(0, windowSec);
      } catch (_) {}
    }

    return LiveReservationRequest(
      id: json['uuid'] as String? ?? json['id'].toString(),
      passengerName: name,
      passengerInitial: name[0].toUpperCase(),
      rating: (passenger['average_rating'] as num?)?.toDouble() ?? 0.0,
      tripsCount: (passenger['trips_count'] as num?)?.toInt() ?? 0,
      isVerified: passenger['is_verified'] as bool? ?? false,
      routeLabel: '$departureCity → $arrivalCity',
      pickupPoint: pickupPoint,
      dropoffPoint: dropoffPoint,
      seats: seats,
      amount: pricePerSeat * seats,
      paymentConfirmed: json['payment_status'] == 'escrow_locked',
      expiresInSeconds: expiresIn,
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      phone: passenger['phone'] as String?,
    );
  }

  static String _resolvePoint(String? point, String? neighborhood, String city) {
    if (point != null && point.isNotEmpty) return point;
    if (neighborhood != null && neighborhood.isNotEmpty) return '$neighborhood, $city';
    return city;
  }

  static ReservationStatus _parseStatus(String s) => switch (s) {
        'accepted'  => ReservationStatus.accepted,
        'rejected'  => ReservationStatus.rejected,
        'cancelled' => ReservationStatus.rejected,
        _           => ReservationStatus.pending,
      };

  // ── Computed ──────────────────────────────────────────────────────────────

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

  Color get borderColor => switch (urgency) {
        ReservationUrgency.critical => const Color(0xFFE53935),
        ReservationUrgency.warning  => const Color(0xFFF59E0B),
        ReservationUrgency.normal   => AppColors.border,
      };

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
}

// ── Controller ───────────────────────────────────────────────────────────────

class ReservationsController extends GetxController {
  BookingService get _service => Get.find<BookingService>();

  final Rx<ReservationTab> selectedTab = ReservationTab.pending.obs;
  final RxBool isLoading = false.obs;

  final RxList<LiveReservationRequest> pendingRequests  = <LiveReservationRequest>[].obs;
  final RxList<LiveReservationRequest> acceptedRequests = <LiveReservationRequest>[].obs;
  final RxList<LiveReservationRequest> rejectedRequests = <LiveReservationRequest>[].obs;

  int get pendingCount  => pendingRequests.length;
  int get acceptedCount => acceptedRequests.length;
  int get rejectedCount => rejectedRequests.length;

  @override
  void onInit() {
    super.onInit();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    isLoading.value = true;
    final result = await _service.fetchDriverBookings();
    isLoading.value = false;

    if (!result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      return;
    }

    final pending  = <LiveReservationRequest>[];
    final accepted = <LiveReservationRequest>[];
    final rejected = <LiveReservationRequest>[];

    for (final json in result.data!) {
      final req = LiveReservationRequest.fromJson(json);
      switch (req.status) {
        case ReservationStatus.pending:
          pending.add(req);
        case ReservationStatus.accepted:
          accepted.add(req);
        case ReservationStatus.rejected:
        case ReservationStatus.expired:
          rejected.add(req);
      }
    }

    pendingRequests.assignAll(pending);
    acceptedRequests.assignAll(accepted);
    rejectedRequests.assignAll(rejected);

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

  Future<void> onAccept(LiveReservationRequest r) async {
    r.cancelTimer();
    final result = await _service.acceptBooking(r.id);

    if (!result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      r.startTimer(() => _onExpired(r));
      return;
    }

    r.status = ReservationStatus.accepted;
    pendingRequests.remove(r);
    acceptedRequests.insert(0, r);
    UIHelper().showSnackBar('MINIZON', '✅ Réservation de ${r.passengerName} acceptée !', 0);
    _loadBookings();
  }

  void onReject(LiveReservationRequest r) => _showRejectDialog(r);

  void _showRejectDialog(LiveReservationRequest r) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Refuser la demande ?',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
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

  Future<void> _confirmReject(LiveReservationRequest r) async {
    r.cancelTimer();
    final result = await _service.rejectBooking(r.id);

    if (!result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      r.startTimer(() => _onExpired(r));
      return;
    }

    r.status = ReservationStatus.rejected;
    pendingRequests.remove(r);
    rejectedRequests.insert(0, r);
    UIHelper().showSnackBar('MINIZON', 'Demande de ${r.passengerName} refusée.', 2);
    _loadBookings();
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(r.passengerInitial,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    )),
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
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () { Get.back(); onChatPassenger(r); },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAccent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 18),
                          SizedBox(width: 8),
                          Text('Chatter',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontSize: 15,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () { Get.back(); onCallPassenger(r); },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Appeler',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 15,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void onChatPassenger(LiveReservationRequest r) {
    if (Get.isBottomSheetOpen ?? false) Get.back();
    Get.toNamed(
      AppRoutes.driverMessageDetail,
      arguments: {
        'uuid': r.id,
        'name': r.passengerName,
        'initial': r.passengerInitial,
      },
    );
  }

  void onContactPassenger(LiveReservationRequest r) {
    _showContactSheet(r);
  }

  void _showContactSheet(LiveReservationRequest r) {
    Get.bottomSheet(
      _ContactSheet(request: r, controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void onCallPassenger(LiveReservationRequest r) {
    final phone = r.phone ?? 'Non disponible';
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(r.passengerInitial,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(r.passengerName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
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
              child: Text(phone,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  )),
            ),
            const SizedBox(height: 8),
            const Text('Numéro masqué pour votre sécurité',
                style: TextStyle(fontSize: 11, color: AppColors.textGhost)),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          if (r.phone != null)
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: phone));
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

  @override
  Future<void> refresh() => _loadBookings();

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

// ── Contact Sheet ─────────────────────────────────────────────────────────────

class _ContactSheet extends StatelessWidget {
  const _ContactSheet({required this.request, required this.controller});
  final LiveReservationRequest request;
  final ReservationsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(request.passengerInitial,
                      style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(request.passengerName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        if (request.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded,
                              color: AppColors.primary, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Contacter le passager',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ContactOption(
            icon: Icons.chat_bubble_outline_rounded,
            iconBg: AppColors.surfaceAccent,
            iconColor: AppColors.primary,
            title: 'Envoyer un message',
            subtitle: 'Discuter via la messagerie MINIZON',
            onTap: () {
              Get.back();
              controller.onChatPassenger(request);
            },
          ),
          const SizedBox(height: 12),
          _ContactOption(
            icon: Icons.call_rounded,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            title: 'Appeler le passager',
            subtitle: request.phone != null
                ? 'Numéro masqué pour votre sécurité'
                : 'Numéro non disponible',
            onTap: () {
              Get.back();
              controller.onCallPassenger(request);
            },
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: double.infinity, height: 46,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('Annuler',
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textGhost, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widget (utilisé dans onViewPassenger) ──────────────────────────────

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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
        ),
      ],
    );
  }
}
