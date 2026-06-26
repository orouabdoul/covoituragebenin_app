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
    this.actionLabel,
    this.actionRoute,
    this.data = const {},
  });

  final String id;
  final DriverNotificationType type;
  final String title;
  final String body;
  final String time;
  bool isRead;
  final String? actionLabel;
  final String? actionRoute;
  final Map<String, dynamic> data;

  IconData get icon {
    return switch (type) {
      DriverNotificationType.reservation => Icons.event_available_rounded,
      DriverNotificationType.payment => Icons.payments_rounded,
      DriverNotificationType.trip => Icons.route_rounded,
      DriverNotificationType.alert => Icons.warning_amber_rounded,
      DriverNotificationType.promotion => Icons.local_offer_rounded,
      DriverNotificationType.support => Icons.support_agent_rounded,
    };
  }

  Color get iconBackground {
    return switch (type) {
      DriverNotificationType.reservation => const Color(0xFF3B82F6),
      DriverNotificationType.payment => const Color(0xFF00A86B),
      DriverNotificationType.trip => const Color(0xFF6366F1),
      DriverNotificationType.alert => const Color(0xFFF59E0B),
      DriverNotificationType.promotion => const Color(0xFFF4B400),
      DriverNotificationType.support => const Color(0xFFA855F7),
    };
  }

  Color get dotColor {
    return switch (type) {
      DriverNotificationType.reservation => const Color(0xFF3B82F6),
      DriverNotificationType.payment => const Color(0xFF00A86B),
      DriverNotificationType.trip => const Color(0xFF6366F1),
      DriverNotificationType.alert => const Color(0xFFF59E0B),
      DriverNotificationType.promotion => const Color(0xFFF4B400),
      DriverNotificationType.support => const Color(0xFFA855F7),
    };
  }

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
