import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/notifications/notifications_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/notification_driver_model.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/modules/principal/driver/reservation/controllers/reservations_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

enum NotifFilterType { all, unread, reservations, payments, trips }

class DriverNotificationsController extends GetxController {
  NotificationsService get _service => Get.find<NotificationsService>();

  final Rx<NotifFilterType> selectedFilter = NotifFilterType.all.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxList<DriverNotificationModel> notifications =
      <DriverNotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _fetch(NotifFilterType.all);
  }

  void selectFilter(NotifFilterType f) {
    selectedFilter.value = f;
    _fetch(f);
  }

  @override
  Future<void> refresh() => _fetch(selectedFilter.value);

  Future<void> _fetch(NotifFilterType f) async {
    isLoading.value = true;
    hasError.value = false;
    final result =
        await _service.fetchNotifications(filter: _filterKey(f));
    isLoading.value = false;
    if (result.isSuccess) {
      final body = result.data!;
      notifications.assignAll(body.notifications);
      unreadCount.value = body.unreadCount;
    } else {
      hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  String _filterKey(NotifFilterType f) => switch (f) {
        NotifFilterType.all          => 'all',
        NotifFilterType.unread       => 'unread',
        NotifFilterType.reservations => 'reservations',
        NotifFilterType.payments     => 'payments',
        NotifFilterType.trips        => 'trips',
      };

  void markAsRead(DriverNotificationModel n) {
    if (n.isRead) return;
    final idx = notifications.indexWhere((x) => x.id == n.id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifications.refresh();
      if (unreadCount.value > 0) {
        unreadCount.value--;
        if (Get.isRegistered<BottonNavController>()) {
          final nav = Get.find<BottonNavController>();
          if (nav.notifBadgeCount.value > 0) nav.notifBadgeCount.value--;
        }
      }
    }
    _service.markAsRead(n.id);
  }

  void markAllRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
    if (Get.isRegistered<BottonNavController>()) {
      Get.find<BottonNavController>().notifBadgeCount.value = 0;
    }
    _service.markAllRead();
  }

  void onNotificationTap(DriverNotificationModel n) {
    markAsRead(n);
    _navigate(n);
  }

  void onAction(DriverNotificationModel n) {
    markAsRead(n);
    _navigate(n);
  }

  void _navigate(DriverNotificationModel n) {
    if (n.actionRoute != null) {
      Get.toNamed(n.actionRoute!);
      return;
    }

    final data        = n.actionData;
    final rawType     = n.rawType;
    final tripUuid    = data['trip_uuid']        as String?;
    final convUuid    = data['conversation_uuid'] as String?;

    switch (rawType) {

      // ── Réservations ──────────────────────────────────────────────────────
      case 'new_booking_request':
      case 'reservation_new':
      case 'booking_status_changed':
      case 'booking_status':          // backend v2
      case 'booking_created':
      case 'reservation_accepted':
      case 'booking_cancelled':
      case 'passenger_cancelled':     // backend v2 — passager annule, conducteur reçoit
      case 'trip_cancelled':
        _goToReservations();
        return;

      // ── Trajet actif ──────────────────────────────────────────────────────
      case 'trip_started':
      case 'trip_reminder':
      case 'departure_reminder':      // backend v2
      case 'boarding_request':
      case 'passenger_boarded':
      case 'passenger_picked_up':
      case 'passenger_no_show':
      case 'passenger_dropped_off':
      case 'boarding_refused':
      case 'admin_alert':
      case 'trip_delay':
      case 'trip_emergency':
        if (tripUuid != null && tripUuid.isNotEmpty) {
          Get.toNamed(AppRoutes.driverActiveTrip, arguments: {'tripUuid': tripUuid});
        } else {
          BottonNavController.goToTab(1);
        }
        return;

      // ── Trajet terminé → revenus ──────────────────────────────────────────
      case 'trip_completed':
      case 'trip_ended':
        BottonNavController.goToTab(2);
        return;

      // ── Statut véhicule ───────────────────────────────────────────────────
      case 'vehicle_status':          // backend v2
        BottonNavController.goToTab(1);
        return;

      // ── Paiements ─────────────────────────────────────────────────────────
      case 'payment_success':
      case 'passenger_payment':       // backend v2
      case 'commission_paid':
        Get.toNamed(AppRoutes.driverPaymentHistory);
        return;

      case 'withdrawal_requested':
      case 'withdrawal_approved':
      case 'withdrawal_rejected':
      case 'withdrawal_processed':
      case 'payout_paid':
        Get.toNamed(AppRoutes.driverWithdraw);
        return;

      // ── Litiges ───────────────────────────────────────────────────────────
      case 'dispute_against_driver':  // backend v2
      case 'dispute_resolved':        // backend v2
        BottonNavController.goToTab(1);
        return;

      // ── Messagerie ────────────────────────────────────────────────────────
      case 'new_message':
      case 'message_new':
        BottonNavController.goToTab(0);
        if (convUuid != null) {
          Get.toNamed(AppRoutes.driverMessageDetail, arguments: {'uuid': convUuid});
        } else {
          Get.toNamed(AppRoutes.driverMessages);
        }
        return;

      // ── Code promo ────────────────────────────────────────────────────────
      case 'promo_code_published':
      case 'promo_published':         // backend v2
        _showPromoSnackbar(
          data['promo_code'] as String? ?? data['code'] as String? ?? '',
          data['discount_value'] as String? ?? data['discount'] as String? ?? '',
        );
        return;

      // ── Avis ─────────────────────────────────────────────────────────────
      case 'review_new':
      case 'review_reply':
        Get.toNamed(AppRoutes.driverReviews);
        return;

      // ── Compte & KYC ─────────────────────────────────────────────────────
      case 'kyc_status_changed':
      case 'kyc_status':              // backend v2
      case 'account_verified':
      case 'document_expiring_soon':
        Get.toNamed(AppRoutes.driverProfile);
        return;

      case 'account_status_changed':
      case 'account_status':          // backend v2
      case 'account_blocked':
      case 'driver_auto_suspended':
        final blocked =
            (data['is_blocked'] ?? data['is_suspended'] ?? '').toString() == 'true';
        if (blocked) {
          _showAccountSuspendedDialog();
        } else {
          _showAccountRestoredSnackbar();
        }
        return;

      case 'driver_warning_issued':
        BottonNavController.goToTab(0);
        return;

      // ── SOS ───────────────────────────────────────────────────────────────
      case 'sos_triggered':
        Get.toNamed(AppRoutes.driverSafetyCenter);
        return;

      // ── Support ───────────────────────────────────────────────────────────
      case 'ticket_resolved':
        Get.toNamed(AppRoutes.driverSupportCenter);
        return;
    }

    // ── Fallback : dériver depuis les clés de actionData (ancien format) ──

    if (data.containsKey('conversation_uuid')) {
      BottonNavController.goToTab(0);
      if (convUuid != null) {
        Get.toNamed(AppRoutes.driverMessageDetail, arguments: {'uuid': convUuid});
      } else {
        Get.toNamed(AppRoutes.driverMessages);
      }
      return;
    }
    if (data.containsKey('booking_uuid')) {
      _goToReservations();
      return;
    }
    if (data.containsKey('trip_uuid')) {
      if (tripUuid != null && tripUuid.isNotEmpty) {
        Get.toNamed(AppRoutes.driverActiveTrip, arguments: {'tripUuid': tripUuid});
      } else {
        BottonNavController.goToTab(1);
      }
      return;
    }

    // ── Fallback final : par type enum ────────────────────────────────────
    switch (n.type) {
      case DriverNotificationType.reservation:
        _goToReservations();
      case DriverNotificationType.payment:
        Get.toNamed(AppRoutes.driverPaymentHistory);
      case DriverNotificationType.trip:
        BottonNavController.goToTab(1);
      case DriverNotificationType.message:
        BottonNavController.goToTab(0);
        Get.toNamed(AppRoutes.driverMessages);
      default:
        break;
    }
  }

  void _goToReservations() {
    if (Get.currentRoute == AppRoutes.driverReservations) {
      if (Get.isRegistered<ReservationsController>()) {
        Get.find<ReservationsController>().refresh();
      }
    } else {
      Get.toNamed(AppRoutes.driverReservations);
    }
  }

  void _showPromoSnackbar(String code, String discount) {
    Get.snackbar(
      'Code promo disponible',
      code.isNotEmpty
          ? 'Utilisez le code $code${discount.isNotEmpty ? ' pour $discount% de réduction' : ''}.'
          : 'Un nouveau code promo est disponible.',
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.local_offer_rounded, color: Colors.white),
      duration: const Duration(seconds: 5),
    );
  }

  void _showAccountRestoredSnackbar() {
    Get.snackbar(
      'Compte restauré',
      'Votre compte a été réactivé. Bienvenue de retour !',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  void _showAccountSuspendedDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.block_rounded, color: AppColors.danger, size: 22),
          SizedBox(width: 10),
          Text('Compte suspendu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        content: const Text(
          'Votre compte a été temporairement suspendu. Contactez le support pour plus d\'informations.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.driverSupportCenter);
            },
            child: const Text('Support',
                style: TextStyle(
                    color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
