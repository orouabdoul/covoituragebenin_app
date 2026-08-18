import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../constants/app_api.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_responsive.dart';
import '../../controller/user_controller.dart';
import '../../utils/app_dio.dart';
import '../../utils/logger.dart';
import '../../../routes/app_routes.dart';
import '../../../modules/principal/driver/messager/controllers/detail_messager_controller.dart'
    show DriverDetailMessagerController;
import '../../../modules/principal/passager/messager/controllers/detail_messager_controller.dart'
    show PassengerDetailMessagerController;

// ── Canaux Android ─────────────────────────────────────────────────────────────

const _chTrip    = 'ch_trip';
const _chPayment = 'ch_payment';
const _chMessage = 'ch_message';
const _chReview  = 'ch_review';
const _chAccount = 'ch_account';
const _chGeneral = 'ch_general';

const _allChannels = [
  AndroidNotificationChannel(
    _chTrip,
    'Trajets & Réservations',
    description: 'Nouvelles réservations, départs, arrivées et annulations',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  ),
  AndroidNotificationChannel(
    _chPayment,
    'Paiements',
    description: 'Paiements reçus, retraits et remboursements',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  ),
  AndroidNotificationChannel(
    _chMessage,
    'Messagerie',
    description: 'Nouveaux messages',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  ),
  AndroidNotificationChannel(
    _chReview,
    'Avis passagers',
    description: 'Nouveaux avis et réponses',
    importance: Importance.defaultImportance,
    playSound: true,
  ),
  AndroidNotificationChannel(
    _chAccount,
    'Compte & Sécurité',
    description: 'Vérification de compte et alertes de sécurité',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  ),
  AndroidNotificationChannel(
    _chGeneral,
    'Informations générales',
    description: 'Actualités et informations de la plateforme',
    importance: Importance.defaultImportance,
    playSound: false,
  ),
];

// ── Helpers top-level ─────────────────────────────────────────────────────────

String _channelForType(String type) {
  switch (type) {
    // Trajets & réservations
    case 'reservation_new':
    case 'reservation_accepted':
    case 'reservation_rejected':
    case 'booking_cancelled':
    case 'trip_cancelled':
    case 'trip_published':
    case 'trip_started':
    case 'trip_proximity':
    case 'trip_ended':
    case 'trip_reminder':
    case 'trip_completed':
    case 'new_booking_request':
    case 'booking_status_changed':
    case 'new_dispute':
      return _chTrip;
    // Paiements
    case 'payment_success':
    case 'payment_confirmed':
    case 'withdrawal_approved':
    case 'withdrawal_rejected':
    case 'withdrawal_requested':
    case 'withdrawal_processed':
    case 'payout_paid':
    case 'refund_approved':
    case 'refund_rejected':
    case 'dispute_status_changed':
      return _chPayment;
    // Messagerie
    case 'message_new':
    case 'new_message':
      return _chMessage;
    // Avis
    case 'review_new':
    case 'review_reply':
      return _chReview;
    // Compte & Sécurité
    case 'account_verified':
    case 'account_blocked':
    case 'account_status_changed':
    case 'kyc_status_changed':
    case 'sos_triggered':
      return _chAccount;
    // Général (promos, infos)
    case 'promo_code_published':
    default:
      return _chGeneral;
  }
}

String _channelNameForId(String id) {
  for (final ch in _allChannels) {
    if (ch.id == id) return ch.name;
  }
  return 'MINIZON';
}

Color _colorForType(String type) {
  switch (type) {
    case 'reservation_new':
    case 'reservation_accepted':
    case 'trip_published':
    case 'trip_reminder':
    case 'new_booking_request':
    case 'trip_completed':
      return const Color(0xFF1565C0);
    case 'trip_started':
    case 'trip_proximity':
    case 'booking_status_changed':
      return const Color(0xFF2E7D32);
    case 'trip_ended':
      return const Color(0xFF1565C0);
    case 'reservation_rejected':
    case 'booking_cancelled':
    case 'trip_cancelled':
    case 'account_blocked':
    case 'account_status_changed':
      return const Color(0xFFB71C1C);
    case 'payment_success':
    case 'payment_confirmed':
    case 'withdrawal_approved':
    case 'refund_approved':
    case 'payout_paid':
      return const Color(0xFF1B5E20);
    case 'withdrawal_rejected':
    case 'refund_rejected':
    case 'dispute_status_changed':
    case 'new_dispute':
      return const Color(0xFFE65100);
    case 'withdrawal_requested':
    case 'withdrawal_processed':
      return const Color(0xFF4527A0);
    case 'message_new':
    case 'new_message':
      return const Color(0xFF4527A0);
    case 'review_new':
    case 'review_reply':
      return const Color(0xFFF57F17);
    case 'account_verified':
    case 'kyc_status_changed':
      return const Color(0xFF2E7D32);
    case 'sos_triggered':
      return const Color(0xFFB71C1C);
    case 'promo_code_published':
      return const Color(0xFFF57F17);
    default:
      return const Color(0xFF1565C0);
  }
}

String? _groupKeyForType(String type, Map<String, dynamic> data) {
  if (type != 'message_new' && type != 'new_message') return null;
  final conv = data['conversation_uuid'] as String? ?? '';
  return conv.isNotEmpty ? 'grp_msg_$conv' : 'grp_messages';
}

String _buildPayload(Map<String, dynamic> data) =>
    data.entries.map((e) => '${e.key}=${e.value}').join('&');

int _notifId() => DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000;

// ── Handler background (isolate séparé) ───────────────────────────────────────

const _silentTypes = {'messages_read', 'message_edited', 'message_deleted'};

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.notification != null) return;

  final data = message.data;
  final type = data['type'] as String? ?? '';

  if (_silentTypes.contains(type)) return;

  final title = data['title'] as String? ?? 'MINIZON';
  final body  = data['body']  as String? ?? '';
  if (body.isEmpty && title == 'MINIZON') return;

  final channelId = _channelForType(type);
  final chName    = _channelNameForId(channelId);
  final color     = _colorForType(type);
  final groupKey  = _groupKeyForType(type, data);

  final plugin = FlutterLocalNotificationsPlugin();

  await plugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@drawable/ic_notification'),
    iOS: DarwinInitializationSettings(),
  ));

  if (Platform.isAndroid) {
    final impl = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    for (final ch in _allChannels) {
      await impl?.createNotificationChannel(ch);
    }
  }

  await plugin.show(
    _notifId(),
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        chName,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        color: color,
        icon: '@drawable/ic_notification',
        groupKey: groupKey,
        setAsGroupSummary: false,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: _buildPayload(data),
  );
}

// ── Service principal ─────────────────────────────────────────────────────────

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final _fcm                = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _initLocalPlugin();
    await _createAllChannels();
    await _requestPermission();
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _listenForeground();
    _listenOnTap();
    _logToken();
  }

  // ── Plugin local ────────────────────────────────────────────────────────────

  Future<void> _initLocalPlugin() async {
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // ── Canaux Android ──────────────────────────────────────────────────────────

  Future<void> _createAllChannels() async {
    if (!Platform.isAndroid) return;
    final impl = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    for (final ch in _allChannels) {
      await impl?.createNotificationChannel(ch);
    }
  }

  // ── Permissions FCM ─────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: false,
    );
    logger.d('FCM permission: ${settings.authorizationStatus}');
  }

  // ── Foreground ──────────────────────────────────────────────────────────────

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      final type = message.data['type'] as String? ?? '';
      if (_handleSilentPush(type, message.data)) return;
      logger.d('FCM foreground: type=$type');
      _showLocalNotification(message);
    });
  }

  bool _handleSilentPush(String type, Map<String, dynamic> data) {
    final convUuid = data['conversation_uuid'] as String? ?? '';
    switch (type) {
      case 'messages_read':
        if (convUuid.isNotEmpty) {
          _routeToActiveChat(convUuid, _SilentAction.read, null, null);
        }
        return true;
      case 'message_edited':
        final msgUuid = data['message_uuid'] as String? ?? '';
        final newBody = data['new_body'] as String? ?? '';
        if (convUuid.isNotEmpty && msgUuid.isNotEmpty) {
          _routeToActiveChat(convUuid, _SilentAction.edit, msgUuid, newBody);
        }
        return true;
      case 'message_deleted':
        final msgUuid = data['message_uuid'] as String? ?? '';
        if (convUuid.isNotEmpty && msgUuid.isNotEmpty) {
          _routeToActiveChat(convUuid, _SilentAction.delete, msgUuid, null);
        }
        return true;
      default:
        return false;
    }
  }

  void _routeToActiveChat(
    String convUuid,
    _SilentAction action,
    String? messageUuid,
    String? newBody,
  ) {
    void apply(dynamic c) {
      switch (action) {
        case _SilentAction.read:
          c.handleMessagesRead(convUuid);
        case _SilentAction.edit:
          c.handleMessageEdited(convUuid, messageUuid!, newBody!);
        case _SilentAction.delete:
          c.handleMessageDeleted(convUuid, messageUuid!);
      }
    }

    if (Get.isRegistered<DriverDetailMessagerController>()) {
      final c = Get.find<DriverDetailMessagerController>();
      if (c.conversationUuid == convUuid) {
        apply(c);
        return;
      }
    }
    if (Get.isRegistered<PassengerDetailMessagerController>()) {
      final c = Get.find<PassengerDetailMessagerController>();
      if (c.conversationUuid == convUuid) apply(c);
    }
  }

  // ── Tap sur notification ────────────────────────────────────────────────────

  void _listenOnTap() {
    FirebaseMessaging.onMessageOpenedApp.listen(_navigateFromMessage);
    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          _navigateFromMessage(message);
        });
      }
    });
  }

  // ── Affichage local (foreground) ────────────────────────────────────────────

  void _showLocalNotification(RemoteMessage message) {
    final data  = message.data;
    final notif = message.notification;
    final title = notif?.title ?? data['title'] as String? ?? 'MINIZON';
    final body  = notif?.body  ?? data['body']  as String? ?? '';
    if (body.isEmpty && title == 'MINIZON') return;

    final type      = data['type'] as String? ?? '';
    final channelId = _channelForType(type);
    final chName    = _channelNameForId(channelId);
    final color     = _colorForType(type);
    final groupKey  = _groupKeyForType(type, data);

    _localNotifications.show(
      _notifId(),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          chName,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          color: color,
          icon: '@drawable/ic_notification',
          groupKey: groupKey,
          setAsGroupSummary: false,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _buildPayload(data),
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    _navigate(_parsePayload(payload));
  }

  void _navigateFromMessage(RemoteMessage message) => _navigate(message.data);

  void _navigate(Map<String, dynamic> data) {
    final type        = data['type'] as String? ?? '';
    final tripUuid    = data['trip_uuid']        as String?;
    final bookingUuid = data['booking_uuid']      as String?;
    final convUuid    = data['conversation_uuid'] as String?;

    final fcmRole   = data['role'] as String? ?? '';
    final localRole = UserController.instance.role.value;
    final role      = fcmRole.isNotEmpty ? fcmRole : localRole;
    final isDriver  = role == 'driver' || role == 'conducteur';

    switch (type) {

      // ── Trajet publié ─────────────────────────────────────────────────────
      case 'trip_published':
        if (!isDriver) Get.toNamed(AppRoutes.passengerHome);

      // ── Nouvelle réservation → conducteur ────────────────────────────────
      case 'new_booking_request':
      case 'reservation_new':
        if (isDriver) Get.toNamed(AppRoutes.driverReservations);

      // ── Changement de statut réservation (les deux rôles) ─────────────────
      case 'booking_status_changed':
        if (isDriver) {
          Get.toNamed(AppRoutes.driverReservations);
        } else {
          if (bookingUuid != null) {
            Get.toNamed(
              AppRoutes.passengerReservationDetail,
              arguments: {'bookingUuid': bookingUuid},
            );
          } else {
            Get.toNamed(AppRoutes.passengerReservations);
          }
        }

      case 'reservation_accepted':
        if (!isDriver) {
          Get.toNamed(
            AppRoutes.passengerWaitingApproval,
            arguments: bookingUuid != null ? {'bookingUuid': bookingUuid} : null,
          );
        }

      case 'reservation_rejected':
        if (!isDriver) Get.toNamed(AppRoutes.passengerReservations);

      case 'booking_cancelled':
        if (isDriver) Get.toNamed(AppRoutes.driverReservations);

      case 'trip_cancelled':
        if (!isDriver) Get.toNamed(AppRoutes.passengerReservations);

      // ── Trajet démarré → passager (live tracking) ─────────────────────────
      case 'trip_started':
        if (!isDriver) {
          Get.toNamed(
            AppRoutes.passengerLiveTracking,
            arguments: {'tripUuid': tripUuid, 'bookingUuid': bookingUuid},
          );
        }

      case 'trip_proximity':
        if (!isDriver) {
          Get.toNamed(
            AppRoutes.passengerDriverArrival,
            arguments: {'tripUuid': tripUuid, 'bookingUuid': bookingUuid},
          );
        }

      // ── Trajet terminé ───────────────────────────────────────────────────
      case 'trip_ended':
        if (!isDriver) {
          Get.toNamed(
            AppRoutes.passengerTripConfirmation,
            arguments: {'tripUuid': tripUuid, 'bookingUuid': bookingUuid},
          );
        }

      case 'trip_completed':
        if (isDriver) {
          Get.toNamed(AppRoutes.driverRevenus);
        } else {
          Get.toNamed(AppRoutes.passengerTripHistory);
        }

      // ── Rappel trajet ─────────────────────────────────────────────────────
      case 'trip_reminder':
        Get.toNamed(
          isDriver ? AppRoutes.driverActiveTrip : AppRoutes.passengerReservations,
        );

      // ── Messagerie ────────────────────────────────────────────────────────
      case 'message_new':
      case 'new_message':
        if (isDriver) {
          Get.toNamed(
            convUuid != null ? AppRoutes.driverMessageDetail : AppRoutes.driverMessages,
            arguments: convUuid != null ? {'uuid': convUuid} : null,
          );
        } else {
          Get.toNamed(
            convUuid != null ? AppRoutes.passengerMessageDetail : AppRoutes.passengerMessages,
            arguments: convUuid != null ? {'uuid': convUuid} : null,
          );
        }

      // ── Paiements ─────────────────────────────────────────────────────────
      case 'payment_success':
        Get.toNamed(
          isDriver ? AppRoutes.driverPaymentHistory : AppRoutes.passengerReservations,
        );

      case 'payment_confirmed':
        if (!isDriver) {
          if (bookingUuid != null) {
            Get.toNamed(
              AppRoutes.passengerReservationDetail,
              arguments: {'bookingUuid': bookingUuid},
            );
          } else {
            Get.toNamed(AppRoutes.passengerReservations);
          }
        }

      // ── Retraits conducteur ───────────────────────────────────────────────
      case 'withdrawal_requested':
      case 'withdrawal_approved':
      case 'withdrawal_rejected':
      case 'withdrawal_processed':
      case 'payout_paid':
        if (isDriver) Get.toNamed(AppRoutes.driverWithdraw);

      // ── Remboursements passager ───────────────────────────────────────────
      case 'refund_approved':
      case 'refund_rejected':
      case 'dispute_status_changed':
        if (!isDriver) Get.toNamed(AppRoutes.passengerRefundHistory);

      // ── Litige (admin) ────────────────────────────────────────────────────
      case 'new_dispute':
        // Pas de route admin dans cette app — ignorer
        break;

      // ── Avis ──────────────────────────────────────────────────────────────
      case 'review_new':
        if (isDriver) Get.toNamed(AppRoutes.driverReviews);

      case 'review_reply':
        if (!isDriver) Get.toNamed(AppRoutes.passengerMyReviews);

      // ── KYC ──────────────────────────────────────────────────────────────
      case 'kyc_status_changed':
        Get.toNamed(
          isDriver ? AppRoutes.driverProfile : AppRoutes.passengerProfile,
        );

      // ── Statut compte ─────────────────────────────────────────────────────
      case 'account_verified':
        Get.toNamed(
          isDriver ? AppRoutes.dashboardDriver : AppRoutes.dashboardPassenger,
        );

      case 'account_blocked':
        _showAccountSuspendedDialog();

      case 'account_status_changed':
        final blocked = (data['is_blocked'] ?? '').toString() == 'true';
        if (blocked) {
          _showAccountSuspendedDialog();
        } else {
          _showAccountRestoredSnackbar();
        }

      // ── Code promo ────────────────────────────────────────────────────────
      case 'promo_code_published':
        _showPromoBottomSheet(
          data['promo_code'] as String? ?? '',
          data['discount_value'] as String? ?? '',
        );

      // ── SOS ──────────────────────────────────────────────────────────────
      case 'sos_triggered':
        Get.toNamed(
          isDriver ? AppRoutes.driverSafetyCenter : AppRoutes.passengerSafetyCenter,
        );

      // ── Listes générales ──────────────────────────────────────────────────
      case 'driver_notifications':
        if (isDriver) Get.toNamed(AppRoutes.driverNotifications);

      case 'passenger_notifications':
        if (!isDriver) Get.toNamed(AppRoutes.passengerNotifications);

      default:
        break;
    }
  }

  // ── UI helpers ──────────────────────────────────────────────────────────────

  void _showAccountSuspendedDialog() {
    Get.dialog(
      _AlertDialogWidget(
        icon: Icons.block_rounded,
        iconColor: const Color(0xFFE53935),
        title: 'Compte suspendu',
        message:
            'Votre compte a été temporairement suspendu. Contactez le support pour plus d\'informations.',
        actionLabel: 'Contacter le support',
        onAction: () {
          Get.back();
          final role = UserController.instance.role.value;
          if (role == 'driver' || role == 'conducteur') {
            Get.toNamed(AppRoutes.driverSupportCenter);
          } else {
            Get.toNamed(AppRoutes.passengerSupportCenter);
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  void _showAccountRestoredSnackbar() {
    Get.snackbar(
      'Compte restauré',
      'Votre compte a été réactivé. Bienvenue de retour !',
      backgroundColor: const Color(0xFF2E7D32),
      colorText: const Color(0xFFFFFFFF),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFFFFFFFF)),
      duration: const Duration(seconds: 4),
    );
  }

  void _showPromoBottomSheet(String promoCode, String discountValue) {
    if (Get.context == null) return;
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PromoBottomSheet(
        promoCode: promoCode,
        discountValue: discountValue,
      ),
    );
  }

  // ── Token FCM ──────────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      logger.e('FCM getToken: $e');
      return null;
    }
  }

  Future<void> registerFcmToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      final uc = UserController.instance;
      final sessionToken = await uc.getSessionToken();
      if (sessionToken.isEmpty) return;
      final role = uc.role.value;
      final dio = AppDio.create();
      final res = await dio.post(
        AppApi.fcmToken,
        data: {
          'fcm_token': token,
          if (role.isNotEmpty) 'role': role,
        },
        options: Options(
          validateStatus: (_) => true,
          headers: {'Authorization': 'Bearer $sessionToken'},
        ),
      );
      if (res.statusCode == 200) {
        logger.d('FCM token enregistré');
      } else if (res.statusCode == 401) {
        logger.w('registerFcmToken: non authentifié [401]');
      } else if (res.statusCode == 422) {
        logger.w('registerFcmToken: token manquant [422]');
      } else {
        logger.w('registerFcmToken: réponse inattendue [${res.statusCode}]');
      }
    } catch (e) {
      logger.e('registerFcmToken: $e');
    }
  }

  void _logToken() {
    _fcm.getToken().then((t) => logger.d('FCM Token: $t'));
    _fcm.onTokenRefresh.listen((t) {
      logger.d('FCM Token refreshed: $t');
      registerFcmToken();
    });
  }

  // ── Helpers payload ────────────────────────────────────────────────────────

  Map<String, dynamic> _parsePayload(String payload) {
    final result = <String, dynamic>{};
    for (final part in payload.split('&')) {
      final idx = part.indexOf('=');
      if (idx > 0) result[part.substring(0, idx)] = part.substring(idx + 1);
    }
    return result;
  }
}

enum _SilentAction { read, edit, delete }

// ── Widgets ───────────────────────────────────────────────────────────────────

class _AlertDialogWidget extends StatelessWidget {
  const _AlertDialogWidget({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Fermer', style: TextStyle(color: AppColors.textHint)),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoBottomSheet extends StatelessWidget {
  const _PromoBottomSheet({
    required this.promoCode,
    required this.discountValue,
  });

  final String promoCode;
  final String discountValue;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.radius(24))),
      ),
      padding: EdgeInsets.fromLTRB(r.w(24), r.h(16), r.w(24), r.h(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: r.w(40),
              height: r.h(4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: r.h(20)),
          Container(
            width: r.w(64),
            height: r.w(64),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_offer_rounded,
              color: const Color(0xFFF59E0B),
              size: r.text(30),
            ),
          ),
          SizedBox(height: r.h(16)),
          Text(
            'Code promo disponible !',
            style: AppTextStyles.title(r),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: r.h(8)),
          if (discountValue.isNotEmpty) ...[
            Text(
              '$discountValue% de réduction sur votre prochaine réservation',
              style: AppTextStyles.body(r).copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r.h(16)),
          ],
          if (promoCode.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.w(24),
                vertical: r.h(12),
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(r.radius(12)),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    promoCode,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: r.text(20),
                      letterSpacing: 2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: r.h(8)),
            Text(
              'Copiez ce code lors de votre réservation',
              style: AppTextStyles.caption(r).copyWith(color: AppColors.textHint),
            ),
          ],
          SizedBox(height: r.h(24)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: Get.back,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.radius(14)),
                ),
                padding: EdgeInsets.symmetric(vertical: r.h(14)),
              ),
              child: const Text(
                'Super, merci !',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
