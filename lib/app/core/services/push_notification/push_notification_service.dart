import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../constants/app_api.dart';
import '../../controller/user_controller.dart';
import '../../utils/app_dio.dart';
import '../../utils/logger.dart';
import '../../../routes/app_routes.dart';
import '../../../modules/principal/driver/messager/controllers/detail_messager_controller.dart'
    show DriverDetailMessagerController;
import '../../../modules/principal/passager/messager/controllers/detail_messager_controller.dart'
    show PassengerDetailMessagerController;

// ── Canaux Android ─────────────────────────────────────────────────────────────
// Un canal par catégorie → l'utilisateur peut gérer son/vibration séparément
// dans les paramètres Android.

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

// ── Helpers top-level (partagés avec l'isolate background) ────────────────────

String _channelForType(String type) {
  switch (type) {
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
      return _chTrip;
    case 'payment_success':
    case 'withdrawal_approved':
    case 'withdrawal_rejected':
    case 'refund_approved':
    case 'refund_rejected':
      return _chPayment;
    case 'message_new':
      return _chMessage;
    case 'review_new':
    case 'review_reply':
      return _chReview;
    case 'account_verified':
    case 'account_blocked':
    case 'sos_triggered':
      return _chAccount;
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
      return const Color(0xFF1565C0);
    case 'trip_started':
    case 'trip_proximity':
      return const Color(0xFF2E7D32);
    case 'trip_ended':
      return const Color(0xFF1565C0);
    case 'reservation_rejected':
    case 'booking_cancelled':
    case 'trip_cancelled':
    case 'account_blocked':
      return const Color(0xFFB71C1C);
    case 'payment_success':
    case 'withdrawal_approved':
    case 'refund_approved':
      return const Color(0xFF1B5E20);
    case 'withdrawal_rejected':
    case 'refund_rejected':
      return const Color(0xFFE65100);
    case 'message_new':
      return const Color(0xFF4527A0);
    case 'review_new':
    case 'review_reply':
      return const Color(0xFFF57F17);
    case 'account_verified':
      return const Color(0xFF2E7D32);
    case 'sos_triggered':
      return const Color(0xFFB71C1C);
    default:
      return const Color(0xFF1565C0);
  }
}

String? _groupKeyForType(String type, Map<String, dynamic> data) {
  if (type != 'message_new') return null;
  final conv = data['conversation_uuid'] as String? ?? '';
  return conv.isNotEmpty ? 'grp_msg_$conv' : 'grp_messages';
}

String _buildPayload(Map<String, dynamic> data) =>
    data.entries.map((e) => '${e.key}=${e.value}').join('&');

// ID unique par notification : timestamp en secondes → évite la collision de hashCode.
int _notifId() => DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000;

// ── Handler background (isolate séparé) ───────────────────────────────────────
// Appelé quand l'app est en arrière-plan ou fermée ET que le message est data-only.
// Si le message a un champ notification, FCM l'affiche automatiquement —
// le handler n'est alors PAS appelé (comportement FCM Android standard).

const _silentTypes = {'messages_read', 'message_edited', 'message_deleted'};

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // FIX 1 : si FCM a déjà affiché la notification (message notification+data),
  // ne pas en afficher une deuxième.
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

  // FIX 3 : initialiser le plugin AVANT de créer les canaux
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

  // FIX 4 : ID basé sur le timestamp pour éviter les collisions
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
    // FIX 3 : initialiser le plugin d'abord, PUIS créer les canaux
    // (resolvePlatformSpecificImplementation peut retourner null avant initialize)

    // 1. Initialiser le plugin local
    await _initLocalPlugin();

    // 2. Créer les canaux Android (après init du plugin)
    await _createAllChannels();

    // 3. Permissions FCM (iOS + Android 13+)
    await _requestPermission();

    // 4. iOS : afficher les notifications même en premier plan
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Listeners
    _listenForeground();
    _listenOnTap();
    // onBackgroundMessage est enregistré dans main.dart avant Firebase.initializeApp()

    // 6. Token
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
    // FIX 2 : NE PAS appeler requestNotificationsPermission() ici —
    // _requestPermission() via _fcm.requestPermission() s'en charge sur Android 13+.
    // Demander deux fois déclenchait la boîte de dialogue deux fois.
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

    // FIX 4 : ID unique basé sur le timestamp
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

    // Rôle depuis la notification (source primaire envoyée par le serveur).
    // Fallback sur le rôle local si le serveur ne l'inclut pas.
    final fcmRole   = data['role'] as String? ?? '';
    final localRole = UserController.instance.role.value;
    final role      = fcmRole.isNotEmpty ? fcmRole : localRole;
    final isDriver  = role == 'driver' || role == 'conducteur';

    switch (type) {

      // ── Trajet publié → passagers uniquement ─────────────────────────────
      case 'trip_published':
        if (!isDriver) Get.toNamed(AppRoutes.passengerHome);

      // ── Réservations ──────────────────────────────────────────────────────
      case 'reservation_new':
        if (isDriver) Get.toNamed(AppRoutes.driverReservations);

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

      // ── Trajet en cours → passagers uniquement ────────────────────────────
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

      case 'trip_ended':
        if (!isDriver) {
          Get.toNamed(
            AppRoutes.passengerTripConfirmation,
            arguments: {'tripUuid': tripUuid, 'bookingUuid': bookingUuid},
          );
        }

      // ── Rappel trajet → les deux rôles ────────────────────────────────────
      case 'trip_reminder':
        Get.toNamed(
          isDriver ? AppRoutes.driverActiveTrip : AppRoutes.passengerReservations,
        );

      // ── Messagerie → les deux rôles ───────────────────────────────────────
      case 'message_new':
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

      case 'withdrawal_approved':
      case 'withdrawal_rejected':
        if (isDriver) Get.toNamed(AppRoutes.driverWithdraw);

      case 'refund_approved':
      case 'refund_rejected':
        if (!isDriver) Get.toNamed(AppRoutes.passengerRefundHistory);

      // ── Avis ──────────────────────────────────────────────────────────────
      case 'review_new':
        if (isDriver) Get.toNamed(AppRoutes.driverReviews);

      case 'review_reply':
        if (!isDriver) Get.toNamed(AppRoutes.passengerMyReviews);

      // ── Compte → les deux rôles ───────────────────────────────────────────
      case 'account_verified':
        Get.toNamed(
          isDriver ? AppRoutes.dashboardDriver : AppRoutes.dashboardPassenger,
        );

      case 'account_blocked':
        break;

      // ── SOS → les deux rôles ─────────────────────────────────────────────
      case 'sos_triggered':
        Get.toNamed(
          isDriver ? AppRoutes.driverSafetyCenter : AppRoutes.passengerSafetyCenter,
        );

      // ── Notifications générales ───────────────────────────────────────────
      case 'driver_notifications':
        if (isDriver) Get.toNamed(AppRoutes.driverNotifications);

      case 'passenger_notifications':
        if (!isDriver) Get.toNamed(AppRoutes.passengerNotifications);

      default:
        break;
    }
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
