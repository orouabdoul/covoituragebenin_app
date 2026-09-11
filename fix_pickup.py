import re

# ─────────────────────────────────────────────────────────────────────────────
# 1. push_notification_service.dart
# ─────────────────────────────────────────────────────────────────────────────
path_pn = r'lib/app/core/services/push_notification/push_notification_service.dart'
with open(path_pn, encoding='utf-8') as f:
    pn = f.read()

# 1a. Ajouter helper _navigateToTab juste avant _navigate
helper = """  // Navigue vers un onglet du dashboard en préservant la bottom nav bar.
  // Fonctionne que l'app soit en foreground, background ou cold-start.
  void _navigateToTab(int tabIndex, {required bool isDriverRole}) {
    final dashboard = isDriverRole
        ? AppRoutes.dashboardDriver
        : AppRoutes.dashboardPassenger;
    if (Get.isRegistered<BottonNavController>()) {
      BottonNavController.goToTab(tabIndex);
    } else {
      Get.offAllNamed(dashboard, arguments: tabIndex);
    }
  }

"""
old_nav_start = "  void _navigate(Map<String, dynamic> data) {"
assert old_nav_start in pn, "anchor _navigate not found"
pn = pn.replace(old_nav_start, helper + old_nav_start)

# 1b. trip_published
pn = pn.replace(
    "      case 'trip_published':\n        if (!isDriver) Get.toNamed(AppRoutes.passengerHome);",
    "      case 'trip_published':\n        if (!isDriver) _navigateToTab(0, isDriverRole: false);",
)

# 1c. booking_status / booking_status_changed — passenger fallback
old = """      case 'booking_status':           // backend v2
      case 'booking_status_changed':
        if (isDriver) {
          Get.toNamed(AppRoutes.driverReservations);
        } else {
          if (bookingUuid != null) {
            Get.toNamed(
              AppRoutes.passengerReservationDetail,
              arguments: {'bookingUuid': bookingUuid},
            );
          } else {
            Get.toNamed(AppRoutes.passengerReservations);
          }
        }"""
new = """      case 'booking_status':           // backend v2
      case 'booking_status_changed':
        if (isDriver) {
          Get.toNamed(AppRoutes.driverReservations);
        } else {
          if (bookingUuid != null) {
            Get.toNamed(
              AppRoutes.passengerReservationDetail,
              arguments: {'bookingUuid': bookingUuid},
            );
          } else {
            _navigateToTab(2, isDriverRole: false);
          }
        }"""
assert old in pn, "booking_status pattern not found"
pn = pn.replace(old, new)

# 1d. reservation_rejected / reservation_cancelled
pn = pn.replace(
    "      case 'reservation_rejected':\n      case 'reservation_cancelled':\n        if (!isDriver) Get.toNamed(AppRoutes.passengerReservations);",
    "      case 'reservation_rejected':\n      case 'reservation_cancelled':\n        if (!isDriver) _navigateToTab(2, isDriverRole: false);",
)

# 1e. booking_created
old = """      case 'booking_created':
        if (isDriver) {
          Get.toNamed(AppRoutes.driverReservations);
        } else {
          Get.toNamed(AppRoutes.passengerReservations);
        }"""
new = """      case 'booking_created':
        if (isDriver) {
          Get.toNamed(AppRoutes.driverReservations);
        } else {
          _navigateToTab(2, isDriverRole: false);
        }"""
assert old in pn, "booking_created pattern not found"
pn = pn.replace(old, new)

# 1f. trip_cancelled
pn = pn.replace(
    "      case 'trip_cancelled':\n        if (!isDriver) Get.toNamed(AppRoutes.passengerReservations);",
    "      case 'trip_cancelled':\n        if (!isDriver) _navigateToTab(2, isDriverRole: false);",
)

# 1g. trip_completed
old = """      case 'trip_completed':
        if (isDriver) {
          Get.toNamed(AppRoutes.driverRevenus);
        } else {
          Get.toNamed(AppRoutes.passengerTripHistory);
        }"""
new = """      case 'trip_completed':
        if (isDriver) {
          _navigateToTab(2, isDriverRole: true);
        } else {
          Get.toNamed(AppRoutes.passengerTripHistory);
        }"""
assert old in pn, "trip_completed pattern not found"
pn = pn.replace(old, new)

# 1h. trip_reminder / departure_reminder
old = """      case 'trip_reminder':
      case 'departure_reminder':       // backend v2
        Get.toNamed(
          isDriver ? AppRoutes.driverActiveTrip : AppRoutes.passengerReservations,
        );"""
new = """      case 'trip_reminder':
      case 'departure_reminder':       // backend v2
        if (isDriver) {
          Get.toNamed(AppRoutes.driverActiveTrip);
        } else {
          _navigateToTab(2, isDriverRole: false);
        }"""
assert old in pn, "trip_reminder pattern not found"
pn = pn.replace(old, new)

# 1i. payment_success
old = """      case 'payment_success':
        Get.toNamed(
          isDriver ? AppRoutes.driverPaymentHistory : AppRoutes.passengerReservations,
        );"""
new = """      case 'payment_success':
        if (isDriver) {
          Get.toNamed(AppRoutes.driverPaymentHistory);
        } else {
          _navigateToTab(2, isDriverRole: false);
        }"""
assert old in pn, "payment_success pattern not found"
pn = pn.replace(old, new)

# 1j. payment_failed / payment_pending
old = """      case 'payment_failed':
      case 'payment_pending':
        if (!isDriver) Get.toNamed(AppRoutes.passengerReservations);
        if (isDriver) Get.toNamed(AppRoutes.driverPaymentHistory);"""
new = """      case 'payment_failed':
      case 'payment_pending':
        if (!isDriver) _navigateToTab(2, isDriverRole: false);
        if (isDriver) Get.toNamed(AppRoutes.driverPaymentHistory);"""
assert old in pn, "payment_failed pattern not found"
pn = pn.replace(old, new)

# 1k. dispute_against_driver → tab 1 conducteur
pn = pn.replace(
    "      case 'dispute_against_driver':   // conducteur : litige ouvert sur son trajet\n        if (isDriver) Get.toNamed(AppRoutes.driverTrips);",
    "      case 'dispute_against_driver':   // conducteur : litige ouvert sur son trajet\n        if (isDriver) _navigateToTab(1, isDriverRole: true);",
)

# 1l. dispute_resolved
old = """      case 'dispute_resolved':         // les deux rôles
        if (isDriver) {
          Get.toNamed(AppRoutes.driverTrips);
        } else {
          Get.toNamed(AppRoutes.passengerRefundHistory);
        }"""
new = """      case 'dispute_resolved':         // les deux rôles
        if (isDriver) {
          _navigateToTab(1, isDriverRole: true);
        } else {
          Get.toNamed(AppRoutes.passengerRefundHistory);
        }"""
assert old in pn, "dispute_resolved pattern not found"
pn = pn.replace(old, new)

# 1m. vehicle_status → tab 1 conducteur
pn = pn.replace(
    "      case 'vehicle_status':           // backend v2\n        if (isDriver) Get.toNamed(AppRoutes.driverTrips);",
    "      case 'vehicle_status':           // backend v2\n        if (isDriver) _navigateToTab(1, isDriverRole: true);",
)

# 1n. admin_alert / trip_delay / trip_emergency fallback
old = """      case 'admin_alert':
      case 'trip_delay':
      case 'trip_emergency':
        if (isDriver) {
          Get.toNamed(
            tripUuid != null ? AppRoutes.driverActiveTrip : AppRoutes.driverTrips,
            arguments: tripUuid != null ? {'tripUuid': tripUuid} : null,
          );
        } else {
          Get.toNamed(
            tripUuid != null ? AppRoutes.passengerLiveTracking : AppRoutes.passengerReservations,
            arguments: tripUuid != null ? {'tripUuid': tripUuid} : null,
          );
        }"""
new = """      case 'admin_alert':
      case 'trip_delay':
      case 'trip_emergency':
        if (isDriver) {
          if (tripUuid != null) {
            Get.toNamed(AppRoutes.driverActiveTrip, arguments: {'tripUuid': tripUuid});
          } else {
            _navigateToTab(1, isDriverRole: true);
          }
        } else {
          if (tripUuid != null) {
            Get.toNamed(AppRoutes.passengerLiveTracking, arguments: {'tripUuid': tripUuid});
          } else {
            _navigateToTab(2, isDriverRole: false);
          }
        }"""
assert old in pn, "admin_alert pattern not found"
pn = pn.replace(old, new)

with open(path_pn, 'w', encoding='utf-8') as f:
    f.write(pn)
print('push_notification_service.dart OK')

# ─────────────────────────────────────────────────────────────────────────────
# 2. Passenger notifications_controller.dart
# ─────────────────────────────────────────────────────────────────────────────
path_pnc = r'lib/app/modules/principal/passager/notifications/controllers/notifications_controller.dart'
with open(path_pnc, encoding='utf-8') as f:
    pnc = f.read()

# 2a. markAsRead — ajouter décrement du badge nav
old = """  void markAsRead(PassengerNotificationModel n) {
    if (n.isRead) return;
    final idx = notifications.indexWhere((x) => x.id == n.id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifications.refresh();
      if (unreadCount.value > 0) unreadCount.value--;
    }
    _service.markAsRead(n.id);
  }"""
new = """  void markAsRead(PassengerNotificationModel n) {
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
  }"""
assert old in pnc, "markAsRead pattern not found"
pnc = pnc.replace(old, new)

# 2b. markAllAsRead — réinitialiser le badge nav
old = """  void markAllAsRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
    _service.markAllRead();
  }"""
new = """  void markAllAsRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
    if (Get.isRegistered<BottonNavController>()) {
      Get.find<BottonNavController>().notifBadgeCount.value = 0;
    }
    _service.markAllRead();
  }"""
assert old in pnc, "markAllAsRead pattern not found"
pnc = pnc.replace(old, new)

# 2c. deleteNotification — décrémenter badge nav si non lu
old = """  void deleteNotification(PassengerNotificationModel n) {
    notifications.remove(n);
    if (!n.isRead && unreadCount.value > 0) unreadCount.value--;
    _service.deleteNotification(n.id);
  }"""
new = """  void deleteNotification(PassengerNotificationModel n) {
    notifications.remove(n);
    if (!n.isRead && unreadCount.value > 0) {
      unreadCount.value--;
      if (Get.isRegistered<BottonNavController>()) {
        final nav = Get.find<BottonNavController>();
        if (nav.notifBadgeCount.value > 0) nav.notifBadgeCount.value--;
      }
    }
    _service.deleteNotification(n.id);
  }"""
assert old in pnc, "deleteNotification pattern not found"
pnc = pnc.replace(old, new)

# 2d. Navigation message — passer par le dashboard
old = """      // ── Messagerie ────────────────────────────────────────────────────────
      case 'new_message':
      case 'message_new':
        final convUuid = data['conversation_uuid'] as String?;
        Get.toNamed(
          convUuid != null
              ? AppRoutes.passengerMessageDetail
              : AppRoutes.passengerMessages,
          arguments: convUuid != null ? {'uuid': convUuid} : null,
        );"""
new = """      // ── Messagerie ────────────────────────────────────────────────────────
      case 'new_message':
      case 'message_new':
        final convUuid = data['conversation_uuid'] as String?;
        BottonNavController.goToTab(3);
        if (convUuid != null) {
          Get.toNamed(AppRoutes.passengerMessageDetail, arguments: {'uuid': convUuid});
        }"""
assert old in pnc, "passenger message nav pattern not found"
pnc = pnc.replace(old, new)

with open(path_pnc, 'w', encoding='utf-8') as f:
    f.write(pnc)
print('passenger notifications_controller.dart OK')

# ─────────────────────────────────────────────────────────────────────────────
# 3. Driver notifications_controller.dart
# ─────────────────────────────────────────────────────────────────────────────
path_dnc = r'lib/app/modules/principal/driver/notifications/controllers/driver_notifications_controller.dart'
with open(path_dnc, encoding='utf-8') as f:
    dnc = f.read()

# 3a. Navigation message — passer par le dashboard
old = """      // ── Messagerie ────────────────────────────────────────────────────────
      case 'new_message':
      case 'message_new':
        final convUuid = data['conversation_uuid'] as String?;
        Get.toNamed(
          convUuid != null
              ? AppRoutes.driverMessageDetail
              : AppRoutes.driverMessages,
          arguments: convUuid != null ? {'uuid': convUuid} : null,
        );
        return;"""
new = """      // ── Messagerie ────────────────────────────────────────────────────────
      case 'new_message':
      case 'message_new':
        final convUuid = data['conversation_uuid'] as String?;
        BottonNavController.goToTab(3);
        if (convUuid != null) {
          Get.toNamed(AppRoutes.driverMessageDetail, arguments: {'uuid': convUuid});
        }
        return;"""
assert old in dnc, "driver message nav pattern not found"
dnc = dnc.replace(old, new)

# 3b. Fallback message (data.containsKey('conversation_uuid'))
old = """    if (data.containsKey('conversation_uuid')) {
      final convUuid = data['conversation_uuid'] as String?;
      Get.toNamed(
        convUuid != null ? AppRoutes.driverMessageDetail : AppRoutes.driverMessages,
        arguments: convUuid != null ? {'uuid': convUuid} : null,
      );
      return;
    }"""
new = """    if (data.containsKey('conversation_uuid')) {
      final convUuid = data['conversation_uuid'] as String?;
      BottonNavController.goToTab(3);
      if (convUuid != null) {
        Get.toNamed(AppRoutes.driverMessageDetail, arguments: {'uuid': convUuid});
      }
      return;
    }"""
assert old in dnc, "driver fallback message pattern not found"
dnc = dnc.replace(old, new)

# 3c. Fallback final par type enum message
old = "      case DriverNotificationType.message:\n        Get.toNamed(AppRoutes.driverMessages);"
new = "      case DriverNotificationType.message:\n        BottonNavController.goToTab(3);"
assert old in dnc, "driver enum message pattern not found"
dnc = dnc.replace(old, new)

with open(path_dnc, 'w', encoding='utf-8') as f:
    f.write(dnc)
print('driver notifications_controller.dart OK')
print('All patches applied successfully!')
