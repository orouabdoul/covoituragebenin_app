import 'package:flutter/material.dart';

enum DriverNotificationType {
  reservation,
  payment,
  trip,
  alert,
  promotion,
  support,
}

class DriverNotificationModel {
  DriverNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.iconData,
    required this.iconBg,
    this.actionLabel,
    this.actionRoute,
    this.actionData = const {},
  });

  final String id;
  final DriverNotificationType type;
  final String title;
  final String body;
  final String time;
  bool isRead;
  final IconData iconData;
  final Color iconBg;
  final String? actionLabel;
  final String? actionRoute;
  final Map<String, dynamic> actionData;

  IconData get icon => iconData;
  Color get iconBackground => iconBg;

  factory DriverNotificationModel.fromJson(Map<String, dynamic> j) {
    final category = j['category'] as String? ?? '';
    final type = _typeFromCategory(category);
    final iconName = j['icon_name'] as String? ?? '';
    final iconBgValue = j['icon_background_color'] as int?;
    final actionData = j['action_data'] as Map<String, dynamic>? ?? {};
    return DriverNotificationModel(
      id: j['id'] as String? ?? '',
      type: type,
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
      time: j['time'] as String? ?? '',
      isRead: j['is_read'] as bool? ?? false,
      iconData: _iconFromName(iconName, type),
      iconBg: iconBgValue != null ? Color(iconBgValue) : _defaultBg(type),
      actionLabel: j['action_label'] as String?,
      actionData: actionData,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static DriverNotificationType _typeFromCategory(String cat) {
    return switch (cat) {
      'reservations' => DriverNotificationType.reservation,
      'payments' => DriverNotificationType.payment,
      'trips' => DriverNotificationType.trip,
      'support' => DriverNotificationType.support,
      _ => DriverNotificationType.alert,
    };
  }

  static const _iconMap = <String, IconData>{
    'person_add_rounded': Icons.person_add_rounded,
    'event_available_rounded': Icons.event_available_rounded,
    'cancel_rounded': Icons.cancel_rounded,
    'check_circle_rounded': Icons.check_circle_rounded,
    'payments_rounded': Icons.payments_rounded,
    'account_balance_wallet_rounded': Icons.account_balance_wallet_rounded,
    'route_rounded': Icons.route_rounded,
    'directions_car_rounded': Icons.directions_car_rounded,
    'flag_rounded': Icons.flag_rounded,
    'timer_rounded': Icons.timer_rounded,
    'warning_amber_rounded': Icons.warning_amber_rounded,
    'local_offer_rounded': Icons.local_offer_rounded,
    'support_agent_rounded': Icons.support_agent_rounded,
    'notifications_rounded': Icons.notifications_rounded,
    'star_rounded': Icons.star_rounded,
  };

  static IconData _iconFromName(String name, DriverNotificationType type) {
    return _iconMap[name] ?? _defaultIcon(type);
  }

  static IconData _defaultIcon(DriverNotificationType type) {
    return switch (type) {
      DriverNotificationType.reservation => Icons.event_available_rounded,
      DriverNotificationType.payment => Icons.payments_rounded,
      DriverNotificationType.trip => Icons.route_rounded,
      DriverNotificationType.alert => Icons.warning_amber_rounded,
      DriverNotificationType.promotion => Icons.local_offer_rounded,
      DriverNotificationType.support => Icons.support_agent_rounded,
    };
  }

  static Color _defaultBg(DriverNotificationType type) {
    return switch (type) {
      DriverNotificationType.reservation => const Color(0xFF3B82F6),
      DriverNotificationType.payment => const Color(0xFF00A86B),
      DriverNotificationType.trip => const Color(0xFF6366F1),
      DriverNotificationType.alert => const Color(0xFFF59E0B),
      DriverNotificationType.promotion => const Color(0xFFF4B400),
      DriverNotificationType.support => const Color(0xFFA855F7),
    };
  }

  // Keep legacy colour/label getters used in some places
  Color get dotColor => iconBg;

  String get typeLabel {
    return switch (type) {
      DriverNotificationType.reservation => 'Réservations',
      DriverNotificationType.payment => 'Paiements',
      DriverNotificationType.trip => 'Trajets',
      DriverNotificationType.alert => 'Alertes',
      DriverNotificationType.promotion => 'Promotions',
      DriverNotificationType.support => 'Assistance',
    };
  }
}

class NotificationsBodyModel {
  const NotificationsBodyModel({
    required this.unreadCount,
    required this.notifications,
  });

  final int unreadCount;
  final List<DriverNotificationModel> notifications;

  factory NotificationsBodyModel.fromJson(Map<String, dynamic> j) =>
      NotificationsBodyModel(
        unreadCount: j['unread_count'] as int? ?? 0,
        notifications: (j['notifications'] as List<dynamic>? ?? [])
            .map((e) =>
                DriverNotificationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
