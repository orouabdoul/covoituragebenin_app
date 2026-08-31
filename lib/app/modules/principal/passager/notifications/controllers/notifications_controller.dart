import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/notifications/passenger_notifications_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/notification_model.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

class NotificationsController extends GetxController {
  PassengerNotificationsService get _service =>
      Get.find<PassengerNotificationsService>();

  final selectedCategory = 'all'.obs;
  final notifications = <PassengerNotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final hasError = false.obs;

  final categories = <Map<String, String>>[
    {'key': 'all',          'label': 'Toutes'},
    {'key': 'unread',       'label': 'Non lues'},
    {'key': 'reservations', 'label': 'Réservations'},
    {'key': 'trips',        'label': 'Trajets'},
    {'key': 'payments',     'label': 'Paiements'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _fetch();
  }

  @override
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    isLoading.value = true;
    hasError.value = false;
    final result = await _service.fetchNotifications(
      filter: selectedCategory.value,
    );
    isLoading.value = false;
    if (result.isSuccess) {
      final body = result.data!;
      notifications.assignAll(body.notifications);
      unreadCount.value = body.unreadCount;
      if (body.categories.isNotEmpty) {
        categories.assignAll(body.categories);
      }
    } else {
      hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  List<PassengerNotificationModel> get filteredNotifications =>
      notifications.toList();

  void selectCategory(String key) {
    if (selectedCategory.value == key) return;
    selectedCategory.value = key;
    _fetch();
  }

  void markAsRead(PassengerNotificationModel n) {
    if (n.isRead) return;
    final idx = notifications.indexWhere((x) => x.id == n.id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifications.refresh();
      if (unreadCount.value > 0) unreadCount.value--;
    }
    _service.markAsRead(n.id);
  }

  void markAllAsRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
    _service.markAllRead();
  }

  void deleteNotification(PassengerNotificationModel n) {
    notifications.remove(n);
    if (!n.isRead && unreadCount.value > 0) unreadCount.value--;
    _service.deleteNotification(n.id);
  }

  void onNotificationTapped(PassengerNotificationModel notif) {
    markAsRead(notif);
    _navigate(notif);
  }

  void onActionTapped(PassengerNotificationModel notif) {
    markAsRead(notif);
    _navigate(notif);
  }

  void _navigate(PassengerNotificationModel notif) {
    final type = notif.type;
    final data = notif.actionData;

    switch (type) {

      // ── Réservations ─────────────────────────────────────────────────────
      case 'new_booking_request':
      case 'reservation_new':
      case 'reservation_accepted':
      case 'reservation_rejected':
      case 'booking_cancelled':
      case 'trip_cancelled':
        BottonNavController.goToTab(2);

      case 'booking_status_changed':
        final bookingUuid = data['booking_uuid'] as String?;
        if (bookingUuid != null) {
          Get.toNamed(
            AppRoutes.passengerReservationDetail,
            arguments: {'bookingUuid': bookingUuid},
          );
        } else {
          BottonNavController.goToTab(2);
        }

      // ── Trajets ───────────────────────────────────────────────────────────
      case 'trip_started':
        final tripUuid    = data['trip_uuid']   as String?;
        final bookingUuid = data['booking_uuid'] as String?;
        Get.toNamed(
          AppRoutes.passengerLiveTracking,
          arguments: {'tripUuid': tripUuid, 'bookingUuid': bookingUuid},
        );

      case 'trip_completed':
      case 'trip_ended':
        Get.toNamed(AppRoutes.passengerTripHistory);

      // ── Paiements ─────────────────────────────────────────────────────────
      case 'payment_confirmed':
      case 'payment_success':
        final bookingUuid = data['booking_uuid'] as String?;
        if (bookingUuid != null) {
          Get.toNamed(
            AppRoutes.passengerReservationDetail,
            arguments: {'bookingUuid': bookingUuid},
          );
        } else {
          BottonNavController.goToTab(2);
        }

      // ── Remboursements ────────────────────────────────────────────────────
      case 'dispute_status_changed':
      case 'refund_approved':
      case 'refund_rejected':
        Get.toNamed(AppRoutes.passengerRefundHistory);

      // ── Messagerie ────────────────────────────────────────────────────────
      case 'new_message':
      case 'message_new':
        final convUuid = data['conversation_uuid'] as String?;
        Get.toNamed(
          convUuid != null
              ? AppRoutes.passengerMessageDetail
              : AppRoutes.passengerMessages,
          arguments: convUuid != null ? {'uuid': convUuid} : null,
        );

      // ── Promo ─────────────────────────────────────────────────────────────
      case 'promo_code_published':
        _showPromoSnackbar(
          data['promo_code'] as String? ?? '',
          data['discount_value'] as String? ?? '',
        );

      // ── Avis ─────────────────────────────────────────────────────────────
      case 'review_reply':
        Get.toNamed(AppRoutes.passengerMyReviews);

      // ── Compte ───────────────────────────────────────────────────────────
      case 'kyc_status_changed':
        Get.toNamed(AppRoutes.passengerProfile);

      case 'account_status_changed':
      case 'account_blocked':
        final blocked = (data['is_blocked'] ?? '').toString() == 'true';
        if (blocked) _showAccountSuspendedDialog();

      case 'account_verified':
        break;

      // ── Fallback catégorie ────────────────────────────────────────────────
      default:
        switch (notif.category) {
          case 'reservations':
          case 'trips':
          case 'payments':
            BottonNavController.goToTab(2);
          default:
            break;
        }
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
              Get.toNamed(AppRoutes.passengerSupportCenter);
            },
            child: const Text('Support',
                style: TextStyle(
                    color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} jours';
  }
}
