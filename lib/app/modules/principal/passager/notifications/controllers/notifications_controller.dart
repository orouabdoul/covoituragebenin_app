import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';

class NotificationsController extends GetxController {
  final selectedCategory = 'all'.obs;
  final notifications = <AppNotification>[].obs;
  final unreadCount = 0.obs;

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
    _loadNotifications();
  }

  void _loadNotifications() {
    final now = DateTime.now();
    notifications.value = [
      AppNotification(
        id: '1',
        category: 'reservations',
        title: 'Réservation acceptée',
        body: 'Koffi Adjovi a accepté votre demande. Passez au paiement pour confirmer votre place.',
        time: now.subtract(const Duration(minutes: 12)),
        isRead: false,
        icon: Icons.check_circle_rounded,
        color: AppColors.primary,
        actionLabel: 'Payer maintenant',
        actionRoute: AppRoutes.passengerReservationPayment,
      ),
      AppNotification(
        id: '2',
        category: 'payments',
        title: 'Paiement confirmé',
        body: '5 250 FCFA payés avec succès pour Cotonou → Parakou. Réf : #TXN-00891',
        time: now.subtract(const Duration(hours: 1, minutes: 30)),
        isRead: false,
        icon: Icons.payments_rounded,
        color: AppColors.blue,
      ),
      AppNotification(
        id: '3',
        category: 'alerts',
        title: 'Conducteur en route',
        body: 'Votre conducteur Yemi Bello arrive dans environ 10 minutes au point de prise en charge.',
        time: now.subtract(const Duration(hours: 2, minutes: 15)),
        isRead: false,
        icon: Icons.directions_car_rounded,
        color: AppColors.warning,
        actionLabel: 'Suivre en direct',
        actionRoute: AppRoutes.passengerDriverArrival,
      ),
      AppNotification(
        id: '4',
        category: 'alerts',
        title: 'Rappel de paiement',
        body: 'Votre trajet Cotonou → Bohicon part dans 1 heure. N\'oubliez pas de payer.',
        time: now.subtract(const Duration(hours: 3)),
        isRead: true,
        icon: Icons.alarm_rounded,
        color: const Color(0xFFEF4444),
        actionLabel: 'Payer',
        actionRoute: AppRoutes.passengerReservationPayment,
      ),
      AppNotification(
        id: '5',
        category: 'reservations',
        title: 'Nouveau trajet disponible',
        body: 'Un trajet Cotonou → Parakou correspond à votre recherche sauvegardée. 3 places disponibles.',
        time: now.subtract(const Duration(days: 1)),
        isRead: true,
        icon: Icons.directions_rounded,
        color: const Color(0xFF8B5CF6),
        actionLabel: 'Voir le trajet',
        actionRoute: AppRoutes.passengerSearch,
      ),
      AppNotification(
        id: '6',
        category: 'promos',
        title: 'Offre spéciale week-end 🎉',
        body: 'Profitez de -20% sur tous vos trajets ce week-end. Code : WEEKEND20',
        time: now.subtract(const Duration(days: 2)),
        isRead: true,
        icon: Icons.local_offer_rounded,
        color: const Color(0xFFF59E0B),
      ),
      AppNotification(
        id: '7',
        category: 'payments',
        title: 'Remboursement traité',
        body: '2 000 FCFA ont été remboursés sur votre compte Mobile Money. Délai : 24-48h.',
        time: now.subtract(const Duration(days: 3)),
        isRead: true,
        icon: Icons.currency_exchange_rounded,
        color: AppColors.primary,
      ),
    ];
    _updateUnreadCount();
  }

  List<AppNotification> get filteredNotifications {
    if (selectedCategory.value == 'all') return notifications.toList();
    return notifications.where((n) => n.category == selectedCategory.value).toList();
  }

  void selectCategory(String key) => selectedCategory.value = key;

  void markAsRead(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !notifications[idx].isRead) {
      final updated = notifications[idx].copyWith(isRead: true);
      notifications[idx] = updated;
      notifications.refresh();
      _updateUnreadCount();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
    notifications.refresh();
    _updateUnreadCount();
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
  }

  void onNotificationTapped(AppNotification notif) {
    markAsRead(notif.id);
    _navigate(notif.actionRoute);
  }

  void onActionTapped(AppNotification notif) {
    markAsRead(notif.id);
    _navigate(notif.actionRoute);
  }

  void _navigate(String? route) {
    if (route == null) return;
    // Les pages principales passent par le bottom nav pour garder la barre visible
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

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
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

class AppNotification {
  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.color,
    this.actionLabel,
    this.actionRoute,
  });

  final String id;
  final String category;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final String? actionRoute;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        category: category,
        title: title,
        body: body,
        time: time,
        isRead: isRead ?? this.isRead,
        icon: icon,
        color: color,
        actionLabel: actionLabel,
        actionRoute: actionRoute,
      );
}
