import 'package:flutter/material.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

class PassengerNotificationModel {
  PassengerNotificationModel({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.body,
    required this.time,
    required this.timeLabel,
    required this.isRead,
    required this.icon,
    required this.color,
    this.actionLabel,
    this.actionData = const {},
  });

  final String id;
  final String type;
  final String category;
  final String title;
  final String body;
  final DateTime time;
  final String timeLabel;
  bool isRead;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final Map<String, dynamic> actionData;

  factory PassengerNotificationModel.fromJson(Map<String, dynamic> j) {
    final topType = (j['type'] ?? '').toString();

    // ── Nouveau format : { id, type, data:{...}, read_at, created_at } ──────
    // ── Ancien format  : { id, type, category, title, body, is_read, ... } ──
    final nested = j['data'] is Map<String, dynamic>
        ? j['data'] as Map<String, dynamic>
        : null;
    final isNewFormat = nested != null;

    final String type;
    final String category;
    final String title;
    final String body;
    final bool isRead;
    final Map<String, dynamic> actionData;
    final String iconName;
    final int? iconBgValue;

    if (isNewFormat) {
      type        = topType;
      category    = _categoryFromType(topType);
      title       = (nested['title'] as String? ?? '').isNotEmpty
          ? nested['title'] as String
          : _titleFromType(topType, nested);
      body        = (nested['body'] as String? ?? '').isNotEmpty
          ? nested['body'] as String
          : _bodyFromType(topType, nested);
      isRead      = j['read_at'] != null;
      actionData  = Map<String, dynamic>.from(nested);
      iconName    = '';
      iconBgValue = null;
    } else {
      type        = topType;
      category    = (j['category'] ?? '').toString();
      title       = (j['title'] ?? '').toString();
      body        = (j['body'] ?? '').toString();
      isRead      = j['is_read'] as bool? ?? false;
      actionData  = j['action_data'] is Map<String, dynamic>
          ? j['action_data'] as Map<String, dynamic>
          : {};
      iconName    = (j['icon_name'] ?? '').toString();
      iconBgValue = j['icon_background_color'] as int?;
    }

    final isoDate    = (j['created_at'] ?? '').toString();
    final parsedTime = DateTime.tryParse(isoDate) ?? DateTime.now();
    final apiLabel   = (j['time'] ?? '').toString();

    return PassengerNotificationModel(
      id:          (j['id'] ?? j['uuid'] ?? '').toString(),
      type:        type,
      category:    category,
      title:       title,
      body:        body,
      time:        parsedTime,
      timeLabel:   apiLabel,
      isRead:      isRead,
      icon:        _iconFromName(iconName, category, type),
      color:       iconBgValue != null
          ? Color(iconBgValue)
          : _defaultColor(category, type),
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
        'driver_approaching' || 'departure_reminder'
            => 'trips',
        'payment_confirmed' || 'payment_success' ||
        'withdrawal_requested' || 'withdrawal_processed' ||
        'withdrawal_approved' || 'withdrawal_rejected' ||
        'payout_paid' || 'refund_approved' || 'refund_rejected' ||
        'dispute_status_changed' || 'dispute_update' || 'dispute_resolved' ||
        'passenger_payment'
            => 'payments',
        'message_new' || 'new_message' => 'messages',
        'promo_code_published' || 'promo_published' => 'promotions',
        'account_status_changed' || 'account_status' ||
        'kyc_status_changed' || 'kyc_status' ||
        'account_verified' || 'account_blocked'
            => 'account',
        _ => 'general',
      };

  // ── Titres dérivés du type ────────────────────────────────────────────────

  static String _titleFromType(String type, Map<String, dynamic> data) =>
      switch (type) {
        'new_booking_request'    => 'Nouvelle réservation',
        'booking_status_changed' => 'Statut de réservation mis à jour',
        'trip_started'           => 'Trajet démarré',
        'trip_completed'         => 'Trajet terminé',
        'trip_ended'             => 'Trajet terminé',
        'payment_confirmed'      => 'Paiement confirmé',
        'new_message' || 'message_new'
            => (data['sender_name'] as String? ?? 'Nouveau message'),
        'withdrawal_requested'   => 'Demande de retrait reçue',
        'withdrawal_processed'   => 'Retrait traité',
        'payout_paid'            => 'Gains virés',
        'dispute_status_changed' => 'Remboursement mis à jour',
        'promo_code_published'   => 'Code promo disponible',
        'account_status_changed' =>
            (data['is_blocked']?.toString() == 'true')
                ? 'Compte suspendu'
                : 'Compte restauré',
        'kyc_status_changed'     =>
            (data['status'] == 'approved') ? 'KYC approuvé' : 'KYC rejeté',
        'account_verified'       => 'Compte vérifié',
        'account_blocked'        => 'Compte suspendu',
        _                        => 'MINIZON',
      };

  // ── Corps dérivé du type ──────────────────────────────────────────────────

  static String _bodyFromType(String type, Map<String, dynamic> data) =>
      switch (type) {
        'new_booking_request'    => 'Un passager a réservé votre trajet.',
        'booking_status_changed' =>
            (data['message'] as String? ?? 'Le statut de votre réservation a changé.'),
        'trip_started'           => 'Votre conducteur a démarré le trajet.',
        'trip_completed' || 'trip_ended'
            => 'Trajet terminé. Laissez un avis !',
        'payment_confirmed'      => 'Votre paiement a bien été confirmé.',
        'new_message' || 'message_new'
            => (data['preview'] as String? ?? 'Vous avez un nouveau message.'),
        'withdrawal_requested'   => 'Votre demande de retrait a été reçue.',
        'withdrawal_processed'   =>
            (data['message'] as String? ?? 'Votre retrait a été traité.'),
        'payout_paid'            => 'Vos gains ont été virés sur votre compte.',
        'dispute_status_changed' =>
            (data['message'] as String? ?? 'Votre demande de remboursement a été mise à jour.'),
        'promo_code_published'   =>
            'Code : ${data['promo_code'] ?? ''} — réduction de ${data['discount_value'] ?? ''}%.',
        'account_status_changed' =>
            (data['is_blocked']?.toString() == 'true')
                ? 'Votre compte a été temporairement suspendu.'
                : 'Votre compte a été réactivé. Bienvenue !',
        'kyc_status_changed'     =>
            (data['status'] == 'approved')
                ? 'Votre identité a été vérifiée avec succès.'
                : 'Votre KYC a été rejeté. Veuillez soumettre à nouveau.',
        _                        => '',
      };

  // ── Icônes ────────────────────────────────────────────────────────────────

  static const _iconMap = <String, IconData>{
    'check_circle_rounded':      Icons.check_circle_rounded,
    'payments_rounded':          Icons.payments_rounded,
    'directions_car_rounded':    Icons.directions_car_rounded,
    'alarm_rounded':             Icons.alarm_rounded,
    'directions_rounded':        Icons.directions_rounded,
    'local_offer_rounded':       Icons.local_offer_rounded,
    'currency_exchange_rounded': Icons.currency_exchange_rounded,
    'notifications_rounded':     Icons.notifications_rounded,
    'warning_amber_rounded':     Icons.warning_amber_rounded,
    'star_rounded':              Icons.star_rounded,
    'cancel_rounded':            Icons.cancel_rounded,
    'schedule_rounded':          Icons.schedule_rounded,
    'person_add_rounded':        Icons.person_add_rounded,
    'event_available_rounded':   Icons.event_available_rounded,
    'route_rounded':             Icons.route_rounded,
    'support_agent_rounded':     Icons.support_agent_rounded,
    'timer_rounded':             Icons.timer_rounded,
    'chat_rounded':              Icons.chat_rounded,
    'account_balance_wallet_rounded': Icons.account_balance_wallet_rounded,
    'badge_rounded':             Icons.badge_rounded,
    'block_rounded':             Icons.block_rounded,
    'flag_rounded':              Icons.flag_rounded,
  };

  static IconData _iconFromName(String name, String category, String type) =>
      _iconMap[name] ?? _defaultIconForType(type, category);

  static IconData _defaultIconForType(String type, String category) =>
      switch (type) {
        'new_booking_request' || 'booking_status_changed' ||
        'reservation_new' || 'reservation_accepted' || 'reservation_rejected'
            => Icons.event_available_rounded,
        'booking_cancelled' || 'trip_cancelled'
            => Icons.cancel_rounded,
        'trip_started'  => Icons.directions_car_rounded,
        'trip_completed' || 'trip_ended' => Icons.flag_rounded,
        'trip_proximity' => Icons.directions_rounded,
        'payment_confirmed' || 'payment_success'
            => Icons.payments_rounded,
        'withdrawal_requested' || 'withdrawal_processed' ||
        'payout_paid'
            => Icons.account_balance_wallet_rounded,
        'dispute_status_changed' || 'refund_approved' || 'refund_rejected'
            => Icons.currency_exchange_rounded,
        'new_message' || 'message_new' => Icons.chat_rounded,
        'promo_code_published'          => Icons.local_offer_rounded,
        'account_status_changed' || 'account_blocked'
            => Icons.block_rounded,
        'account_verified' || 'kyc_status_changed'
            => Icons.badge_rounded,
        _ => switch (category) {
              'reservations' => Icons.event_available_rounded,
              'trips'        => Icons.directions_car_rounded,
              'payments'     => Icons.payments_rounded,
              'messages'     => Icons.chat_rounded,
              _              => Icons.notifications_rounded,
            },
      };

  // ── Couleurs ──────────────────────────────────────────────────────────────

  static Color _defaultColor(String category, String type) => switch (type) {
        'new_booking_request' || 'reservation_new' || 'reservation_accepted'
            => AppColors.primary,
        'booking_status_changed' || 'trip_started'
            => AppColors.success,
        'reservation_rejected' || 'booking_cancelled' || 'trip_cancelled' ||
        'account_blocked' || 'account_status_changed'
            => AppColors.danger,
        'trip_completed' || 'trip_ended'
            => AppColors.primary,
        'payment_confirmed' || 'payment_success' || 'payout_paid'
            => AppColors.successDark,
        'withdrawal_requested' || 'withdrawal_processed'
            => AppColors.primary,
        'dispute_status_changed'
            => AppColors.accent,
        'new_message' || 'message_new'
            => AppColors.primary,
        'promo_code_published'
            => AppColors.warning,
        'account_verified' || 'kyc_status_changed'
            => AppColors.success,
        _ => switch (category) {
              'reservations' => AppColors.primary,
              'trips'        => AppColors.primary,
              'payments'     => AppColors.primary,
              'messages'     => AppColors.primary,
              _              => AppColors.danger,
            },
      };
}

class PassengerNotificationsBodyModel {
  const PassengerNotificationsBodyModel({
    required this.unreadCount,
    required this.notifications,
    required this.categories,
  });

  final int unreadCount;
  final List<PassengerNotificationModel> notifications;
  final List<Map<String, String>> categories;

  factory PassengerNotificationsBodyModel.fromJson(Map<String, dynamic> j) =>
      PassengerNotificationsBodyModel(
        unreadCount: j['unread_count'] as int? ?? 0,
        notifications: (j['notifications'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((e) => PassengerNotificationModel.fromJson(e))
            .toList(),
        categories: (j['categories'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map((c) => {
                  'key':   (c['key']   ?? '').toString(),
                  'label': (c['label'] ?? '').toString(),
                })
            .where((c) => c['key']!.isNotEmpty)
            .toList(),
      );
}
