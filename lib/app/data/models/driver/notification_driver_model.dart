import 'package:flutter/material.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

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
      final rawBody = (j['body'] ?? '').toString();
      body         = rawBody.isNotEmpty ? rawBody : _bodyFromType(topType, j);
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
      time:        _formatCreatedAt(j['created_at'] ?? j['updated_at']),
      isRead:      isRead,
      iconData:    icon,
      iconBg:      bg,
      actionLabel: j['action_label']?.toString(),
      actionData:  actionData,
    );
  }

  // ── Mapping type → catégorie ──────────────────────────────────────────────

  static String _categoryFromType(String type) => switch (type) {
        'new_booking_request' || 'booking_status_changed' || 'booking_status' ||
        'booking_created' ||
        'reservation_new' || 'reservation_accepted' || 'reservation_rejected' ||
        'booking_cancelled' || 'trip_cancelled' || 'passenger_cancelled'
            => 'reservations',
        'trip_started' || 'trip_completed' || 'trip_ended' ||
        'trip_proximity' || 'trip_reminder' || 'trip_published' ||
        'driver_approaching' || 'departure_reminder' || 'vehicle_status' ||
        'admin_alert' || 'trip_delay' || 'trip_emergency'
            => 'trips',
        'payment_confirmed' || 'payment_success' ||
        'withdrawal_requested' || 'withdrawal_processed' ||
        'withdrawal_approved' || 'withdrawal_rejected' ||
        'payout_paid' || 'refund_approved' || 'refund_rejected' ||
        'passenger_payment' || 'commission_paid' ||
        'dispute_against_driver' || 'dispute_update' || 'dispute_resolved'
            => 'payments',
        'message_new' || 'new_message' => 'messages',
        'promo_code_published' || 'promo_published' => 'promotions',
        'ticket_resolved' || 'admin_broadcast' => 'support',
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

  static String _bodyFromType(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'new_booking_request':
        return 'Un passager a réservé votre trajet.';
      case 'booking_status_changed':
        return data['message'] as String? ?? 'Le statut de votre réservation a changé.';
      case 'trip_started':
        return 'Le trajet est en cours.';
      case 'trip_completed':
      case 'trip_ended':
        return 'Trajet terminé. Consultez vos revenus.';
      case 'payment_success':
        return 'Un passager a payé sa réservation.';
      case 'withdrawal_requested':
        return 'Votre demande de retrait a été reçue.';
      case 'withdrawal_processed':
        return data['message'] as String? ?? 'Votre retrait a été traité.';
      case 'payout_paid':
        return 'Vos gains ont été virés sur votre compte.';
      case 'new_message':
      case 'message_new':
        return _extractMessagePreview(data);
      case 'promo_code_published':
        return 'Code : ${data['promo_code'] ?? ''} — réduction de ${data['discount_value'] ?? ''}%.';
      case 'account_status_changed':
        return data['is_blocked']?.toString() == 'true'
            ? 'Votre compte a été temporairement suspendu.'
            : 'Votre compte a été réactivé.';
      case 'kyc_status_changed':
        return data['status'] == 'approved'
            ? 'Votre identité a été vérifiée.'
            : 'Votre KYC a été rejeté.';
      default:
        // Catch-all pour tout type contenant "message"
        if (type.toLowerCase().contains('message')) {
          return _extractMessagePreview(data);
        }
        return '';
    }
  }

  static String _extractMessagePreview(Map<String, dynamic> data) {
    for (final key in ['preview', 'message', 'content', 'text', 'body']) {
      final v = (data[key] as String?)?.trim() ?? '';
      if (v.isNotEmpty) return v;
    }
    return 'Vous avez un nouveau message.';
  }

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
            => AppColors.primary,
        'booking_status_changed'       => AppColors.success,
        'reservation_rejected' || 'booking_cancelled' || 'trip_cancelled' ||
        'account_blocked' || 'account_status_changed'
            => AppColors.danger,
        'trip_started'                 => AppColors.success,
        'trip_completed' || 'trip_ended' => AppColors.primary,
        'payment_success'              => AppColors.successDark,
        'withdrawal_requested' || 'withdrawal_processed'
            => AppColors.primary,
        'payout_paid'                  => AppColors.successDark,
        'new_message' || 'message_new' => AppColors.primary,
        'promo_code_published'         => AppColors.warning,
        'kyc_status_changed' || 'account_verified' => AppColors.success,
        _ => switch (type) {
              DriverNotificationType.reservation => AppColors.primary,
              DriverNotificationType.payment     => AppColors.primary,
              DriverNotificationType.trip        => AppColors.primary,
              DriverNotificationType.alert       => AppColors.warning,
              DriverNotificationType.promotion   => AppColors.warning,
              DriverNotificationType.support     => AppColors.primary,
              DriverNotificationType.message     => AppColors.primary,
            },
      };

  // ── Helper date ───────────────────────────────────────────────────────────

  static String _formatCreatedAt(dynamic raw) {
    if (raw == null) return '';
    final s = raw.toString().trim();
    if (s.isEmpty) return '';
    // Tente ISO8601, puis avec remplacement espace→T (format Laravel sans T)
    DateTime? dt = DateTime.tryParse(s);
    if (dt == null) dt = DateTime.tryParse(s.replaceFirst(' ', 'T'));
    if (dt == null) return '';
    final local = dt.isUtc ? dt.toLocal() : dt;
    final diff = DateTime.now().difference(local);
    if (diff.isNegative || diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 30) return 'Il y a ${diff.inDays} j';
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    return '$d/$m/${local.year}';
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
