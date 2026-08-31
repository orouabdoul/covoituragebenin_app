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
      if (unreadCount.value > 0) unreadCount.value--;
    }
    _service.markAsRead(n.id);
  }

  void markAllRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
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

    final data    = n.actionData;
    final rawType = n.rawType;

    // ── Routing par type précis (nouveau backend) ─────────────────────────

    switch (rawType) {

      // ── Nouvelles réservations ────────────────────────────────────────────
      case 'new_booking_request':
      case 'reservation_new':
      case 'booking_status_changed':
      case 'reservation_accepted':
      case 'booking_cancelled':
      case 'trip_cancelled':
        _goToReservations();
        return;

      // ── Trajets ───────────────────────────────────────────────────────────
      case 'trip_started':
      case 'trip_completed':
      case 'trip_ended':
      case 'trip_reminder':
        BottonNavController.goToTab(1);
        return;

      // ── Paiements ─────────────────────────────────────────────────────────
      case 'payment_success':
        BottonNavController.goToTab(2);
        return;

      case 'withdrawal_requested':
      case 'withdrawal_approved':
      case 'withdrawal_rejected':
      case 'withdrawal_processed':
      case 'payout_paid':
        Get.toNamed(AppRoutes.driverWithdraw);
        return;

      // ── Messagerie ────────────────────────────────────────────────────────
      case 'new_message':
      case 'message_new':
        final convUuid = data['conversation_uuid'] as String?;
        Get.toNamed(
          convUuid != null
              ? AppRoutes.driverMessageDetail
              : AppRoutes.driverMessages,
          arguments: convUuid != null ? {'uuid': convUuid} : null,
        );
        return;

      // ── Code promo ────────────────────────────────────────────────────────
      case 'promo_code_published':
        _showPromoSnackbar(
          data['promo_code'] as String? ?? '',
          data['discount_value'] as String? ?? '',
        );
        return;

      // ── Avis ─────────────────────────────────────────────────────────────
      case 'review_new':
      case 'review_reply':
        Get.toNamed(AppRoutes.driverReviews);
        return;

      // ── Compte & KYC ─────────────────────────────────────────────────────
      case 'kyc_status_changed':
      case 'account_verified':
        Get.toNamed(AppRoutes.driverProfile);
        return;

      case 'account_status_changed':
      case 'account_blocked':
        final blocked = (data['is_blocked'] ?? '').toString() == 'true';
        if (blocked) _showAccountSuspendedDialog();
        return;
    }

    // ── Fallback : dériver depuis les clés de actionData (ancien format) ──

    if (data.containsKey('conversation_uuid')) {
      final convUuid = data['conversation_uuid'] as String?;
      Get.toNamed(
        convUuid != null ? AppRoutes.driverMessageDetail : AppRoutes.driverMessages,
        arguments: convUuid != null ? {'uuid': convUuid} : null,
      );
      return;
    }
    if (data.containsKey('booking_uuid')) {
      _goToReservations();
      return;
    }
    if (data.containsKey('trip_uuid')) {
      BottonNavController.goToTab(1);
      return;
    }

    // ── Fallback final : par type enum ────────────────────────────────────
    switch (n.type) {
      case DriverNotificationType.reservation:
        _goToReservations();
      case DriverNotificationType.payment:
        BottonNavController.goToTab(2);
      case DriverNotificationType.trip:
        BottonNavController.goToTab(1);
      case DriverNotificationType.message:
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
