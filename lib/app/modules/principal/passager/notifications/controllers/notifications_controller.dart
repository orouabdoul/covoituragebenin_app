import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/notifications/passenger_notifications_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/notification_model.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class NotificationsController extends GetxController {
  PassengerNotificationsService get _service =>
      Get.find<PassengerNotificationsService>();

  final selectedCategory = 'all'.obs;
  final notifications = <PassengerNotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final hasError = false.obs;

  final List<Map<String, String>> categories = const [
    {'key': 'all', 'label': 'Tout'},
    {'key': 'reservations', 'label': 'Réservations'},
    {'key': 'payments', 'label': 'Paiements'},
    {'key': 'promos', 'label': 'Promos'},
    {'key': 'alerts', 'label': 'Alertes'},
  ];

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
    } else {
      hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  List<PassengerNotificationModel> get filteredNotifications {
    if (selectedCategory.value == 'all') return notifications.toList();
    return notifications
        .where((n) => n.category == selectedCategory.value)
        .toList();
  }

  void selectCategory(String key) {
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
    final route = notif.actionRoute;
    if (route == null) return;
    if (route == AppRoutes.passengerSearch) {
      BottonNavController.goToTab(1);
    } else if (route == AppRoutes.passengerReservations) {
      BottonNavController.goToTab(2);
    } else if (route == AppRoutes.passengerMessages) {
      BottonNavController.goToTab(3);
    } else {
      Get.toNamed(route);
    }
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
