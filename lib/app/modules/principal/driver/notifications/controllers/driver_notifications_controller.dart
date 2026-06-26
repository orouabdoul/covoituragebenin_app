import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../models/notification_driver_model.dart';

enum NotifFilterType { all, unread, reservations, payments, trips }

class DriverNotificationsController extends GetxController {
  final Rx<NotifFilterType> selectedFilter = NotifFilterType.all.obs;

  final RxList<DriverNotificationModel> notifications = <DriverNotificationModel>[
    DriverNotificationModel(
      id: 'n1', type: DriverNotificationType.payment,
      title: 'Paiement confirmé',
      body: 'Aminata Koné a payé 2 500 FCFA pour votre trajet.',
      time: 'Il y a 5 min', isRead: false,
      actionLabel: 'Voir les revenus',
      actionRoute: AppRoutes.driverRevenus,
    ),
    DriverNotificationModel(
      id: 'n2', type: DriverNotificationType.reservation,
      title: 'Nouvelle réservation',
      body: 'Kwame Asante demande 1 place pour Cotonou → Porto-Novo.',
      time: 'Il y a 12 min', isRead: false,
      actionLabel: 'Voir la demande',
      actionRoute: AppRoutes.driverReservations,
    ),
    DriverNotificationModel(
      id: 'n3', type: DriverNotificationType.trip,
      title: 'Rappel : départ dans 1h',
      body: 'Votre trajet Cotonou → Porto-Novo part à 14h30.',
      time: 'Il y a 30 min', isRead: true,
      actionLabel: 'Voir le trajet',
      actionRoute: AppRoutes.driverTrips,
    ),
    DriverNotificationModel(
      id: 'n4', type: DriverNotificationType.payment,
      title: 'Fonds disponibles',
      body: '4 500 FCFA sont maintenant disponibles dans votre wallet.',
      time: 'Hier 18:00', isRead: true,
      actionLabel: 'Retirer',
      actionRoute: AppRoutes.driverWithdraw,
    ),
    DriverNotificationModel(
      id: 'n5', type: DriverNotificationType.promotion,
      title: 'Bonus weekend',
      body: 'Gagnez 5 000 FCFA supplémentaires ce weekend !',
      time: 'Il y a 2h', isRead: true,
    ),
    DriverNotificationModel(
      id: 'n6', type: DriverNotificationType.reservation,
      title: 'Avis reçu',
      body: 'Aminata Koné vous a attribué 5 étoiles.',
      time: 'Il y a 3h', isRead: true,
      actionLabel: 'Voir l\'avis',
      actionRoute: AppRoutes.driverReviews,
    ),
  ].obs;

  List<DriverNotificationModel> get filteredNotifications {
    return switch (selectedFilter.value) {
      NotifFilterType.all => notifications,
      NotifFilterType.unread => notifications.where((n) => !n.isRead).toList(),
      NotifFilterType.reservations => notifications.where((n) => n.type == DriverNotificationType.reservation).toList(),
      NotifFilterType.payments => notifications.where((n) => n.type == DriverNotificationType.payment).toList(),
      NotifFilterType.trips => notifications.where((n) => n.type == DriverNotificationType.trip).toList(),
    };
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  void selectFilter(NotifFilterType f) => selectedFilter.value = f;

  void markAsRead(DriverNotificationModel n) {
    final idx = notifications.indexWhere((x) => x.id == n.id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifications.refresh();
    }
  }

  void markAllRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }

  void onNotificationTap(DriverNotificationModel n) {
    markAsRead(n);
    if (n.actionRoute != null) {
      Get.toNamed(n.actionRoute!);
    }
  }

  void onAction(DriverNotificationModel n) {
    markAsRead(n);
    if (n.actionRoute != null) {
      Get.toNamed(n.actionRoute!);
    } else {
      UIHelper().showSnackBar('MINIZON', n.title, 1);
    }
  }
}
