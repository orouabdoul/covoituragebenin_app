import 'package:flutter/material.dart';

enum DriverNotificationType {
  reservation,
  payment,
  trip,
  alert,
  promotion,
  support,
  message,
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
    this.rawType = '',
    this.actionLabel,
    this.actionRoute,
    this.actionData = const {},
  });

  final String id;
  final DriverNotificationType type;
  final String rawType;
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
    final topType = (j['type'] ?? '').toString();

    // ── Nouveau format : { id, type, data:{...}, read_at, created_at } ──────
    // ── Ancien format  : { id, type, category, title, body, is_read, ... } ──
    final nested = j['data'] is Map<String, dynamic>
        ? j['data'] as Map<String, dynamic>
        : null;
    final isNewFormat = nested != null;

    final String resolvedType;
    final String category;
    final String title;
    final String body;
    final bool isRead;
    final Map<String, dynamic> actionData;
    String iconName;
    int? iconBgValue;

    if (isNewFormat) {
      resolvedType = topType;
      category     = _categoryFromType(topType);
      title        = (nested['title'] as String? ?? '').isNotEmpty
          ? nested['title'] as String
          : _titleFromType(topType, nested);
      body         = (nested['body'] as String? ?? '').isNotEmpty
          ? nested['body'] as String
          : _bodyFromType(topType, nested);
      isRead       = j['read_at'] != null;
      actionData   = Map<String, dynamic>.from(nested);
      iconName     = '';
      iconBgValue  = null;
    } else {
      resolvedType = topType;
      category     = (j['category'] ?? '').toString();
      title        = (j['title'] ?? '').toString();
      body         = (j['body'] ?? '').toString();
      isRead       = j['is_read'] as bool? ?? false;
      actionData   = j['action_data'] is Map<String, dynamic>
          ? j['action_data'] as Map<String, dynamic>
          : {};
      iconName     = (j['icon_name'] ?? '').toString();
      iconBgValue  = j['icon_background_color'] as int?;
    }

    final notifType = _typeFromCategory(category, resolvedType);
    final icon = _iconFromName(iconName, notifType, resolvedType);
    final bg   = iconBgValue != null ? Color(iconBgValue) : _defaultBg(notifType, resolvedType);

    return DriverNotificationModel(
      id:          (j['id'] ?? '').toString(),
      type:        notifType,
      rawType:     resolvedType,
      title:       title,
      body:        body,
      time:        (j['time'] ?? _formatCreatedAt(j['created_at'])).toString(),
      isRead:      isRead,
      iconData:    icon,
      iconBg:      bg,
      actionLabel: j['action_label']?.toString(),
      actionData:  actionData,
    );
  }

  // ── Mapping type → catégorie ──────────────────────────────────────────────

  static String _categoryFromType(String type) => switch (type) {
        'new_booking_request' || 'booking_status_changed' ||
        'reservation_new' || 'reservation_accepted' || 'reservation_rejected' ||
        'booking_cancelled' || 'trip_cancelled'
            => 'reservations',
        'trip_started' || 'trip_completed' || 'trip_ended' ||
        'trip_proximity' || 'trip_reminder' || 'trip_published'
            => 'trips',
        'payment_confirmed' || 'payment_success' ||
        'withdrawal_requested' || 'withdrawal_processed' ||
        'withdrawal_approved' || 'withdrawal_rejected' ||
        'payout_paid' || 'refund_approved' || 'refund_rejected'
            => 'payments',
        'message_new' || 'new_message' => 'messages',
        'promo_code_published'          => 'promotions',
        _ => 'support',
      };

  static DriverNotificationType _typeFromCategory(String cat, String type) {
    if (type == 'new_message' || type == 'message_new') {
      return DriverNotificationType.message;
    }
    if (type == 'promo_code_published') return DriverNotificationType.promotion;
    return switch (cat) {
      'reservations' => DriverNotificationType.reservation,
      'payments'     => DriverNotificationType.payment,
      'trips'        => DriverNotificationType.trip,
      'messages'     => DriverNotificationType.message,
      'support'      => DriverNotificationType.support,
      _              => DriverNotificationType.alert,
    };
  }

  // ── Titres dérivés du type ────────────────────────────────────────────────

  static String _titleFromType(String type, Map<String, dynamic> data) =>
      switch (type) {
        'new_booking_request'    => 'Nouvelle réservation',
        'booking_status_changed' => 'Statut de réservation mis à jour',
        'trip_started'           => 'Trajet démarré',
        'trip_completed' || 'trip_ended' => 'Trajet terminé',
        'payment_success'        => 'Paiement reçu',
        'withdrawal_requested'   => 'Demande de retrait reçue',
        'withdrawal_processed'   => 'Retrait traité',
        'payout_paid'            => 'Gains virés',
        'new_message' || 'message_new'
            => (data['sender_name'] as String? ?? 'Nouveau message'),
        'promo_code_published'   => 'Code promo disponible',
        'account_status_changed' =>
            (data['is_blocked']?.toString() == 'true')
                ? 'Compte suspendu'
                : 'Compte restauré',
        'kyc_status_changed'     =>
            (data['status'] == 'approved') ? 'KYC approuvé' : 'KYC rejeté',
        'account_verified'       => 'Compte vérifié',
        _                        => 'MINIZON',
      };

  // ── Corps dérivé du type ──────────────────────────────────────────────────

  static String _bodyFromType(String type, Map<String, dynamic> data) =>
      switch (type) {
        'new_booking_request'    => 'Un passager a réservé votre trajet.',
        'booking_status_changed' =>
            (data['message'] as String? ?? 'Le statut de votre réservation a changé.'),
        'trip_started'           => 'Le trajet est en cours.',
        'trip_completed' || 'trip_ended'
            => 'Trajet terminé. Consultez vos revenus.',
        'payment_success'        => 'Un passager a payé sa réservation.',
        'withdrawal_requested'   => 'Votre demande de retrait a été reçue.',
        'withdrawal_processed'   =>
            (data['message'] as String? ?? 'Votre retrait a été traité.'),
        'payout_paid'            => 'Vos gains ont été virés sur votre compte.',
        'new_message' || 'message_new'
            => (data['preview'] as String? ?? 'Vous avez un nouveau message.'),
        'promo_code_published'   =>
            'Code : ${data['promo_code'] ?? ''} — réduction de ${data['discount_value'] ?? ''}%.',
        'account_status_changed' =>
            (data['is_blocked']?.toString() == 'true')
                ? 'Votre compte a été temporairement suspendu.'
                : 'Votre compte a été réactivé.',
        'kyc_status_changed'     =>
            (data['status'] == 'approved')
                ? 'Votre identité a été vérifiée.'
                : 'Votre KYC a été rejeté.',
        _                        => '',
      };

  // ── Icônes ────────────────────────────────────────────────────────────────

  static const _iconMap = <String, IconData>{
    'person_add_rounded':            Icons.person_add_rounded,
    'event_available_rounded':       Icons.event_available_rounded,
    'cancel_rounded':                Icons.cancel_rounded,
    'check_circle_rounded':          Icons.check_circle_rounded,
    'payments_rounded':              Icons.payments_rounded,
    'account_balance_wallet_rounded': Icons.account_balance_wallet_rounded,
    'route_rounded':                 Icons.route_rounded,
    'directions_car_rounded':        Icons.directions_car_rounded,
    'flag_rounded':                  Icons.flag_rounded,
    'timer_rounded':                 Icons.timer_rounded,
    'warning_amber_rounded':         Icons.warning_amber_rounded,
    'local_offer_rounded':           Icons.local_offer_rounded,
    'support_agent_rounded':         Icons.support_agent_rounded,
    'notifications_rounded':         Icons.notifications_rounded,
    'star_rounded':                  Icons.star_rounded,
    'chat_rounded':                  Icons.chat_rounded,
    'badge_rounded':                 Icons.badge_rounded,
    'block_rounded':                 Icons.block_rounded,
    'currency_exchange_rounded':     Icons.currency_exchange_rounded,
  };

  static IconData _iconFromName(
      String name, DriverNotificationType type, String rawType) {
    return _iconMap[name] ?? _defaultIconForRawType(rawType, type);
  }

  static IconData _defaultIconForRawType(
      String rawType, DriverNotificationType type) =>
      switch (rawType) {
        'new_booking_request' || 'reservation_new' => Icons.person_add_rounded,
        'booking_status_changed' || 'reservation_accepted'
            => Icons.event_available_rounded,
        'reservation_rejected' || 'booking_cancelled' || 'trip_cancelled'
            => Icons.cancel_rounded,
        'trip_started'                => Icons.directions_car_rounded,
        'trip_completed' || 'trip_ended' => Icons.flag_rounded,
        'payment_success'             => Icons.payments_rounded,
        'withdrawal_requested' || 'withdrawal_processed' || 'payout_paid'
            => Icons.account_balance_wallet_rounded,
        'new_message' || 'message_new' => Icons.chat_rounded,
        'promo_code_published'         => Icons.local_offer_rounded,
        'account_status_changed' || 'account_blocked' => Icons.block_rounded,
        'kyc_status_changed' || 'account_verified' => Icons.badge_rounded,
        _ => _defaultIcon(type),
      };

  static IconData _defaultIcon(DriverNotificationType type) =>
      switch (type) {
        DriverNotificationType.reservation => Icons.event_available_rounded,
        DriverNotificationType.payment     => Icons.payments_rounded,
        DriverNotificationType.trip        => Icons.route_rounded,
        DriverNotificationType.alert       => Icons.warning_amber_rounded,
        DriverNotificationType.promotion   => Icons.local_offer_rounded,
        DriverNotificationType.support     => Icons.support_agent_rounded,
        DriverNotificationType.message     => Icons.chat_rounded,
      };

  // ── Couleurs ──────────────────────────────────────────────────────────────

  static Color _defaultBg(DriverNotificationType type, String rawType) =>
      switch (rawType) {
        'new_booking_request' || 'reservation_new' || 'reservation_accepted'
            => const Color(0xFF3B82F6),
        'booking_status_changed'       => const Color(0xFF2E7D32),
        'reservation_rejected' || 'booking_cancelled' || 'trip_cancelled' ||
        'account_blocked' || 'account_status_changed'
            => const Color(0xFFE53935),
        'trip_started'                 => const Color(0xFF2E7D32),
        'trip_completed' || 'trip_ended' => const Color(0xFF6366F1),
        'payment_success'              => const Color(0xFF1B5E20),
        'withdrawal_requested' || 'withdrawal_processed'
            => const Color(0xFF7C3AED),
        'payout_paid'                  => const Color(0xFF1B5E20),
        'new_message' || 'message_new' => const Color(0xFF4527A0),
        'promo_code_published'         => const Color(0xFFF59E0B),
        'kyc_status_changed' || 'account_verified' => const Color(0xFF2E7D32),
        _ => switch (type) {
              DriverNotificationType.reservation => const Color(0xFF3B82F6),
              DriverNotificationType.payment     => const Color(0xFF7C3AED),
              DriverNotificationType.trip        => const Color(0xFF6366F1),
              DriverNotificationType.alert       => const Color(0xFFF59E0B),
              DriverNotificationType.promotion   => const Color(0xFFF4B400),
              DriverNotificationType.support     => const Color(0xFFA855F7),
              DriverNotificationType.message     => const Color(0xFF4527A0),
            },
      };

  // ── Helper date ───────────────────────────────────────────────────────────

  static String _formatCreatedAt(dynamic raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return raw.toString();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} jours';
  }

  // ── Legacy getters ────────────────────────────────────────────────────────

  Color get dotColor => iconBg;

  String get typeLabel => switch (type) {
        DriverNotificationType.reservation => 'Réservations',
        DriverNotificationType.payment     => 'Paiements',
        DriverNotificationType.trip        => 'Trajets',
        DriverNotificationType.alert       => 'Alertes',
        DriverNotificationType.promotion   => 'Promotions',
        DriverNotificationType.support     => 'Assistance',
        DriverNotificationType.message     => 'Messages',
      };
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
