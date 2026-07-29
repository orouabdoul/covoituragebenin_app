import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/notifications/passenger_notifications_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/notification_model.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';

class NotificationsController extends GetxController {
  PassengerNotificationsService get _service =>
      Get.find<PassengerNotificationsService>();

  final selectedCategory = 'all'.obs;
  final notifications = <PassengerNotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final hasError = false.obs;

  // Seed with API spec categories; replaced by API response on first successful fetch
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

  // Filtering is server-side; the list already contains the correct items
  List<PassengerNotificationModel> get filteredNotifications => notifications.toList();

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
    switch (notif.category) {
      case 'reservations':
      case 'trips':
        BottonNavController.goToTab(2);
        break;
      case 'payments':
        BottonNavController.goToTab(2);
        break;
      default:
        break;
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
