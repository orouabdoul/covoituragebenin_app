import 'package:flutter/material.dart';

class PassengerNotificationModel {
  PassengerNotificationModel({
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
    this.actionData = const {},
  });

  final String id;
  final String category;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final String? actionRoute;
  final Map<String, dynamic> actionData;

  factory PassengerNotificationModel.fromJson(Map<String, dynamic> j) {
    final category = j['category'] as String? ?? '';
    final iconName = j['icon_name'] as String? ?? '';
    final iconBgValue = j['icon_background_color'] as int?;
    final timeStr = j['created_at'] as String? ?? j['time'] as String? ?? '';
    return PassengerNotificationModel(
      id: j['id']?.toString() ?? '',
      category: category,
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
      time: DateTime.tryParse(timeStr) ?? DateTime.now(),
      isRead: j['is_read'] as bool? ?? false,
      icon: _iconFromName(iconName, category),
      color: iconBgValue != null ? Color(iconBgValue) : _defaultColor(category),
      actionLabel: j['action_label'] as String?,
      actionRoute: j['action_route'] as String?,
      actionData: j['action_data'] as Map<String, dynamic>? ?? {},
    );
  }

  static const _iconMap = <String, IconData>{
    'check_circle_rounded': Icons.check_circle_rounded,
    'payments_rounded': Icons.payments_rounded,
    'directions_car_rounded': Icons.directions_car_rounded,
    'alarm_rounded': Icons.alarm_rounded,
    'directions_rounded': Icons.directions_rounded,
    'local_offer_rounded': Icons.local_offer_rounded,
    'currency_exchange_rounded': Icons.currency_exchange_rounded,
    'notifications_rounded': Icons.notifications_rounded,
    'warning_amber_rounded': Icons.warning_amber_rounded,
    'star_rounded': Icons.star_rounded,
    'cancel_rounded': Icons.cancel_rounded,
    'schedule_rounded': Icons.schedule_rounded,
    'person_add_rounded': Icons.person_add_rounded,
    'event_available_rounded': Icons.event_available_rounded,
    'route_rounded': Icons.route_rounded,
    'support_agent_rounded': Icons.support_agent_rounded,
    'timer_rounded': Icons.timer_rounded,
  };

  static IconData _iconFromName(String name, String category) =>
      _iconMap[name] ?? _defaultIcon(category);

  static IconData _defaultIcon(String category) => switch (category) {
        'reservations' => Icons.event_available_rounded,
        'payments' => Icons.payments_rounded,
        'promos' => Icons.local_offer_rounded,
        _ => Icons.notifications_rounded,
      };

  static Color _defaultColor(String category) => switch (category) {
        'reservations' => const Color(0xFF00A86B),
        'payments' => const Color(0xFF3B82F6),
        'promos' => const Color(0xFFF59E0B),
        _ => const Color(0xFFEF4444),
      };
}

class PassengerNotificationsBodyModel {
  const PassengerNotificationsBodyModel({
    required this.unreadCount,
    required this.notifications,
  });

  final int unreadCount;
  final List<PassengerNotificationModel> notifications;

  factory PassengerNotificationsBodyModel.fromJson(Map<String, dynamic> j) =>
      PassengerNotificationsBodyModel(
        unreadCount: j['unread_count'] as int? ?? 0,
        notifications: (j['notifications'] as List<dynamic>? ?? [])
            .map((e) =>
                PassengerNotificationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
