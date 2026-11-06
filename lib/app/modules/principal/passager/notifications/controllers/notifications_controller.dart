import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/notifications/passenger_notifications_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/notification_model.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/modules/tracking/passenger/trajet_attente/controllers/trajet_attente_controller.dart'
    show TrajetAttenteController;
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

  void markAllAsRead() {
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

  void deleteNotification(PassengerNotificationModel n) {
    notifications.remove(n);
    if (!n.isRead && unreadCount.value > 0) {
      unreadCount.value--;
      if (Get.isRegistered<BottonNavController>()) {
        final nav = Get.find<BottonNavController>();
        if (nav.notifBadgeCount.value > 0) nav.notifBadgeCount.value--;
      }
    }
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
    final type        = notif.type;
    final data        = notif.actionData;
    final tripUuid    = data['trip_uuid']        as String?;
    final bookingUuid = data['booking_uuid']      as String?;
    final convUuid    = data['conversation_uuid'] as String?;

    switch (type) {

      // ── Réservations ─────────────────────────────────────────────────────
      case 'new_booking_request':
      case 'reservation_new':
      case 'booking_created':
      case 'reservation_rejected':
      case 'reservation_cancelled':
      case 'booking_cancelled':
      case 'trip_cancelled':
      case 'trip_cancelled_driver_absent':
        BottonNavController.goToTab(1);

      case 'reservation_accepted':
      case 'reservation_confirmed':
        Get.toNamed(
          AppRoutes.passengerWaitingApproval,
          arguments: bookingUuid != null ? {'bookingUuid': bookingUuid} : null,
        );

      case 'booking_status':          // backend v2
      case 'booking_status_changed':
        if (bookingUuid != null) {
          Get.toNamed(
            AppRoutes.passengerReservationDetail,
            arguments: {'bookingUuid': bookingUuid},
          );
        } else {
          BottonNavController.goToTab(1);
        }

      // ── Trajet en attente ─────────────────────────────────────────────────
      case 'driver_en_route':
      case 'trip_reminder':
      case 'departure_reminder':      // backend v2
        Get.toNamed(
          AppRoutes.passengerTripPending,
          arguments: {
            if (tripUuid    != null) 'tripUuid':    tripUuid,
            if (bookingUuid != null) 'bookingUuid': bookingUuid,
          },
        );

      case 'boarding_request':
        if (Get.isRegistered<TrajetAttenteController>()) {
          Get.find<TrajetAttenteController>().onBoardingRequest(
            bookingUuid:  bookingUuid ?? '',
            driverLat:    double.tryParse(data['driver_lat']?.toString() ?? ''),
            driverLng:    double.tryParse(data['driver_lng']?.toString() ?? ''),
            boardingCode: data['boarding_code'] as String? ?? '',
          );
        } else {
          Get.toNamed(
            AppRoutes.passengerTripPending,
            arguments: {
              if (tripUuid    != null) 'tripUuid':    tripUuid,
              if (bookingUuid != null) 'bookingUuid': bookingUuid,
              'openBoarding': true,
              if ((data['driver_lat'] ?? '').toString().isNotEmpty)
                'driverLat': data['driver_lat'],
              if ((data['driver_lng'] ?? '').toString().isNotEmpty)
                'driverLng': data['driver_lng'],
              if ((data['boarding_code'] ?? '').toString().isNotEmpty)
                'boardingCode': data['boarding_code'],
            },
          );
        }

      case 'trip_proximity':
      case 'driver_nearby':
      case 'driver_arriving':
      case 'driver_approaching':      // backend v2
        Get.toNamed(
          AppRoutes.passengerDriverArrival,
          arguments: {
            if (tripUuid    != null) 'tripUuid':    tripUuid,
            if (bookingUuid != null) 'bookingUuid': bookingUuid,
          },
        );

      // ── Trajet en cours ───────────────────────────────────────────────────
      case 'trip_started':
      case 'passenger_picked_up':
        Get.toNamed(
          AppRoutes.passengerLiveTracking,
          arguments: {
            if (tripUuid    != null) 'tripUuid':    tripUuid,
            if (bookingUuid != null) 'bookingUuid': bookingUuid,
          },
        );

      case 'trip_ended':
      case 'passenger_dropped_off':
        Get.toNamed(
          AppRoutes.passengerTripConfirmation,
          arguments: {
            if (tripUuid    != null) 'tripUuid':    tripUuid,
            if (bookingUuid != null) 'bookingUuid': bookingUuid,
          },
        );

      case 'trip_completed':
        Get.toNamed(AppRoutes.passengerTripHistory);

      // ── Paiements ─────────────────────────────────────────────────────────
      case 'payment_confirmed':
      case 'payment_success':
        if (bookingUuid != null) {
          Get.toNamed(
            AppRoutes.passengerReservationDetail,
            arguments: {'bookingUuid': bookingUuid},
          );
        } else {
          BottonNavController.goToTab(1);
        }

      case 'payment_failed':
      case 'payment_pending':
        BottonNavController.goToTab(1);

      // ── Remboursements & litiges ──────────────────────────────────────────
      case 'dispute_status_changed':
      case 'dispute_update':          // backend v2
      case 'dispute_resolved':        // backend v2
      case 'refund_approved':
      case 'refund_rejected':
        Get.toNamed(AppRoutes.passengerRefundHistory);

      // ── Messagerie ────────────────────────────────────────────────────────
      case 'new_message':
      case 'message_new':
        BottonNavController.goToTab(2);
        if (convUuid != null) {
          Get.toNamed(AppRoutes.passengerMessageDetail, arguments: {'uuid': convUuid});
        }

      // ── Promo ─────────────────────────────────────────────────────────────
      case 'promo_code_published':
      case 'promo_published':         // backend v2
        _showPromoSnackbar(
          data['promo_code'] as String? ?? data['code'] as String? ?? '',
          data['discount_value'] as String? ?? data['discount'] as String? ?? '',
        );

      // ── Avis ─────────────────────────────────────────────────────────────
      case 'review_reply':
        Get.toNamed(AppRoutes.passengerMyReviews);

      // ── Compte ───────────────────────────────────────────────────────────
      case 'kyc_status_changed':
      case 'kyc_status':              // backend v2
        Get.toNamed(AppRoutes.passengerProfile);

      case 'account_status_changed':
      case 'account_status':          // backend v2
      case 'account_blocked':
        final blocked =
            (data['is_blocked'] ?? data['is_suspended'] ?? '').toString() == 'true';
        if (blocked) {
          _showAccountSuspendedDialog();
        } else {
          _showAccountRestoredSnackbar();
        }

      case 'account_verified':
        break;

      // ── SOS ──────────────────────────────────────────────────────────────
      case 'sos_triggered':
        Get.toNamed(AppRoutes.passengerSafetyCenter);

      // ── Support ───────────────────────────────────────────────────────────
      case 'ticket_resolved':
        Get.toNamed(AppRoutes.passengerSupportCenter);

      // ── Fallback catégorie ────────────────────────────────────────────────
      default:
        switch (notif.category) {
          case 'reservations':
          case 'trips':
          case 'payments':
            BottonNavController.goToTab(1);
          default:
            break;
        }
    }
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
    final local = time.isUtc ? time.toLocal() : time;
    final diff = DateTime.now().difference(local);
    if (diff.isNegative || diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    if (diff.inDays < 30) {
      final weeks = diff.inDays ~/ 7;
      return 'Il y a $weeks sem';
    }
    if (diff.inDays < 365) {
      final months = diff.inDays ~/ 30;
      return 'Il y a $months mois';
    }
    final years = diff.inDays ~/ 365;
    return 'Il y a $years an${years > 1 ? 's' : ''}';
  }
}
