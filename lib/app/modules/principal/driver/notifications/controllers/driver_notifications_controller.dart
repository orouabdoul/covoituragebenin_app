import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/notifications/notifications_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/notification_driver_model.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/modules/principal/driver/reservation/controllers/reservations_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

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
        NotifFilterType.all => 'all',
        NotifFilterType.unread => 'unread',
        NotifFilterType.reservations => 'reservations',
        NotifFilterType.payments => 'payments',
        NotifFilterType.trips => 'trips',
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
    // Derive destination from action_data keys first, then fall back to type.
    // Pages qui sont des onglets du bottom nav utilisent goToTab pour
    // préserver la barre de navigation.
    final data = n.actionData;
    if (data.containsKey('booking_uuid')) {
      _goToReservations();
      return;
    }
    if (data.containsKey('trip_uuid')) {
      BottonNavController.goToTab(1); // Trajets tab
      return;
    }
    switch (n.type) {
      case DriverNotificationType.reservation:
        _goToReservations();
      case DriverNotificationType.payment:
        BottonNavController.goToTab(2); // Revenus tab
      case DriverNotificationType.trip:
        BottonNavController.goToTab(1); // Trajets tab
      default:
        break;
    }
  }

  // Évite le cycle CLOSE/GOING quand la route est déjà active
  void _goToReservations() {
    if (Get.currentRoute == AppRoutes.driverReservations) {
      if (Get.isRegistered<ReservationsController>()) {
        Get.find<ReservationsController>().refresh();
      }
    } else {
      Get.toNamed(AppRoutes.driverReservations);
    }
  }
}
