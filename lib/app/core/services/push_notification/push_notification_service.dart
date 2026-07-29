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

// ── Canaux Android ─────────────────────────────────────────────────────────────
// Un canal distinct par catégorie → l'utilisateur peut régler son/vibration
// de chaque type séparément dans les paramètres Android.

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
    description: 'Nouveaux messages de passagers',
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
  return 'Covoiturage Bénin';
}

Color _colorForType(String type) {
  switch (type) {
    case 'reservation_new':
    case 'reservation_accepted':
    case 'trip_published':
    case 'trip_reminder':
      return const Color(0xFF1565C0); // bleu conducteur
    case 'trip_started':
    case 'trip_proximity':
      return const Color(0xFF2E7D32); // vert — trajet en cours
    case 'trip_ended':
      return const Color(0xFF1565C0);
    case 'reservation_rejected':
    case 'booking_cancelled':
    case 'trip_cancelled':
    case 'account_blocked':
      return const Color(0xFFB71C1C); // rouge — annulation
    case 'payment_success':
    case 'withdrawal_approved':
    case 'refund_approved':
      return const Color(0xFF1B5E20); // vert foncé — argent
    case 'withdrawal_rejected':
    case 'refund_rejected':
      return const Color(0xFFE65100); // orange — refus
    case 'message_new':
      return const Color(0xFF4527A0); // violet — messagerie
    case 'review_new':
    case 'review_reply':
      return const Color(0xFFF57F17); // ambre — avis
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

// ── Handler background (isolate séparé) ───────────────────────────────────────
// Appelé quand l'app est en arrière-plan ou fermée.
// Doit être top-level et annoté @pragma.

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final data  = message.data;
  final notif = message.notification;
  final title = notif?.title ?? data['title'] as String? ?? 'Covoiturage Bénin';
  final body  = notif?.body  ?? data['body']  as String? ?? '';
  if (body.isEmpty && title == 'Covoiturage Bénin') return;

  final type      = data['type'] as String? ?? '';
  final channelId = _channelForType(type);
  final chName    = _channelNameForId(channelId);
  final color     = _colorForType(type);
  final groupKey  = _groupKeyForType(type, data);

  final plugin = FlutterLocalNotificationsPlugin();

  if (Platform.isAndroid) {
    final impl = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    for (final ch in _allChannels) {
      await impl?.createNotificationChannel(ch);
    }
  }

  await plugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@drawable/ic_notification'),
    iOS: DarwinInitializationSettings(),
  ));

  await plugin.show(
    message.hashCode,
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
    // 1. Créer tous les canaux Android
    await _createAllChannels();

    // 2. Initialiser le plugin local (foreground + tap)
    await _initLocalPlugin();

    // 3. Permissions (Android 13+ / iOS)
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
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 6. Token
    _logToken();
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

  // ── Initialisation plugin local ─────────────────────────────────────────────

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
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
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
  // Android n'affiche pas les notifications FCM au premier plan → on les montre
  // via flutter_local_notifications avec le bon canal et la bonne couleur.

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      logger.d('FCM foreground: type=${message.data['type']}');
      _showLocalNotification(message);
    });
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
    final title = notif?.title ?? data['title'] as String? ?? 'Covoiturage Bénin';
    final body  = notif?.body  ?? data['body']  as String? ?? '';
    if (body.isEmpty && title == 'Covoiturage Bénin') return;

    final type      = data['type'] as String? ?? '';
    final channelId = _channelForType(type);
    final chName    = _channelNameForId(channelId);
    final color     = _colorForType(type);
    final groupKey  = _groupKeyForType(type, data);

    _localNotifications.show(
      message.hashCode,
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
    final role        = data['role'] as String? ?? '';
    final tripUuid    = data['trip_uuid']        as String?;
    final bookingUuid = data['booking_uuid']      as String?;
    final convUuid    = data['conversation_uuid'] as String?;

    switch (type) {
      case 'trip_published':
        Get.toNamed(AppRoutes.passengerHome);

      case 'reservation_new':
        Get.toNamed(AppRoutes.driverReservations);

      case 'reservation_accepted':
        Get.toNamed(
          AppRoutes.passengerWaitingApproval,
          arguments: bookingUuid != null ? {'booking_uuid': bookingUuid} : null,
        );

      case 'reservation_rejected':
        Get.toNamed(AppRoutes.passengerReservations);

      case 'booking_cancelled':
        Get.toNamed(AppRoutes.driverReservations);

      case 'trip_cancelled':
        Get.toNamed(AppRoutes.passengerReservations);

      case 'trip_started':
        Get.toNamed(
          AppRoutes.passengerLiveTracking,
          arguments: {'tripUuid': tripUuid, 'bookingUuid': bookingUuid},
        );

      case 'trip_proximity':
        Get.toNamed(
          AppRoutes.passengerDriverArrival,
          arguments: {'tripUuid': tripUuid, 'bookingUuid': bookingUuid},
        );

      case 'trip_ended':
        Get.toNamed(
          AppRoutes.passengerTripConfirmation,
          arguments: {'tripUuid': tripUuid, 'bookingUuid': bookingUuid},
        );

      case 'trip_reminder':
        Get.toNamed(
          role == 'driver' ? AppRoutes.driverActiveTrip : AppRoutes.passengerReservations,
        );

      case 'message_new':
        if (role == 'driver') {
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

      case 'payment_success':
        Get.toNamed(
          role == 'driver' ? AppRoutes.driverPaymentHistory : AppRoutes.passengerReservations,
        );

      case 'withdrawal_approved':
      case 'withdrawal_rejected':
        Get.toNamed(AppRoutes.driverWithdraw);

      case 'refund_approved':
      case 'refund_rejected':
        Get.toNamed(AppRoutes.passengerRefundHistory);

      case 'review_new':
        Get.toNamed(AppRoutes.driverReviews);

      case 'review_reply':
        Get.toNamed(AppRoutes.passengerMyReviews);

      case 'account_verified':
        Get.toNamed(
          role == 'driver' ? AppRoutes.dashboardDriver : AppRoutes.dashboardPassenger,
        );

      case 'account_blocked':
        break;

      case 'sos_triggered':
        Get.toNamed(
          role == 'driver' ? AppRoutes.driverSafetyCenter : AppRoutes.passengerSafetyCenter,
        );

      case 'driver_notifications':
        Get.toNamed(AppRoutes.driverNotifications);

      case 'passenger_notifications':
        Get.toNamed(AppRoutes.passengerNotifications);

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
      final sessionToken = await UserController.instance.getSessionToken();
      if (sessionToken.isEmpty) return;
      final dio = AppDio.create();
      final res = await dio.post(
        AppApi.fcmToken,
        data: {'fcm_token': token},
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
