import 'dart:io';

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

const _channelId   = 'covoiturage_benin_high';
const _channelName = 'Covoiturage Bénin';
const _channelDesc = 'Réservations, trajets et messages importants';

// ── Handler background (isolate séparé) ───────────────────────────────────────
// Appelé quand l'app est en arrière-plan ou fermée et reçoit un message FCM.
// Doit être top-level et annoté @pragma.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final notification = message.notification;
  final title = notification?.title
      ?? message.data['title'] as String?
      ?? 'Covoiturage Bénin';
  final body = notification?.body
      ?? message.data['body'] as String?
      ?? '';
  if (body.isEmpty && title == 'Covoiturage Bénin') return;

  // Dans un isolate background, on crée un plugin local frais.
  final plugin = FlutterLocalNotificationsPlugin();

  if (Platform.isAndroid) {
    // Créer le canal (idempotent : sans effet si déjà existant)
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ));
  }

  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  await plugin.show(
    message.hashCode,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}

// ── Service principal ─────────────────────────────────────────────────────────

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final _fcm               = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Canal Android haute priorité avec son
    await _createAndroidChannel();

    // 2. Plugin local (foreground + tap)
    await _initLocalNotifications();

    // 3. Permission (Android 13+ / iOS)
    await _requestPermission();

    // 4. iOS : afficher les notifications même quand l'app est au premier plan
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Listeners
    _listenForeground();
    _listenOnTap();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 6. Log token + refresh
    _logToken();
  }

  // ── Canal Android ────────────────────────────────────────────────────────────

  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ));
  }

  // ── Initialisation plugin local ──────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    // Demande explicite de la permission Android 13+ via flutter_local_notifications
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  // ── Permission ───────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: false,
    );
    logger.d('FCM permission: ${settings.authorizationStatus}');
  }

  // ── Foreground ───────────────────────────────────────────────────────────────
  // Sur Android, Firebase n'affiche PAS la notification automatiquement
  // quand l'app est au premier plan → on la montre via flutter_local_notifications.

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      logger.d('FCM foreground: type=${message.data['type']} title=${message.notification?.title}');
      _showLocalNotification(message);
    });
  }

  // ── Tap sur notification ─────────────────────────────────────────────────────

  void _listenOnTap() {
    // App en arrière-plan → tap sur notification FCM système
    FirebaseMessaging.onMessageOpenedApp.listen(_navigateFromMessage);

    // App fermée → tap sur notification → app s'ouvre
    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          _navigateFromMessage(message);
        });
      }
    });
  }

  // ── Affichage local (foreground) ─────────────────────────────────────────────

  void _showLocalNotification(RemoteMessage message) {
    // Supporte les messages avec ET sans champ notification (data-only)
    final notification = message.notification;
    final title = notification?.title
        ?? message.data['title'] as String?
        ?? 'Covoiturage Bénin';
    final body = notification?.body
        ?? message.data['body'] as String?
        ?? '';
    if (body.isEmpty && title == 'Covoiturage Bénin') return;

    _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _buildPayload(message.data),
    );
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    _navigate(_parsePayload(payload));
  }

  void _navigateFromMessage(RemoteMessage message) {
    _navigate(message.data);
  }

  void _navigate(Map<String, dynamic> data) {
    final type        = data['type'] as String? ?? '';
    final role        = data['role'] as String? ?? '';
    final tripUuid    = data['trip_uuid']        as String?;
    final bookingUuid = data['booking_uuid']      as String?;
    final convUuid    = data['conversation_uuid'] as String?;

    switch (type) {

      // ── Nouveau trajet publié ────────────────────────────────────────────────
      // Le conducteur vient de publier un trajet → les passagers voient la recherche
      case 'trip_published':
        Get.toNamed(AppRoutes.passengerHome);

      // ── Réservations ─────────────────────────────────────────────────────────
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

      // ── Trajet en cours ──────────────────────────────────────────────────────
      case 'trip_started':
        Get.toNamed(
          AppRoutes.passengerLiveTracking,
          arguments: {
            if (tripUuid    != null) 'tripUuid':    tripUuid,
            if (bookingUuid != null) 'bookingUuid': bookingUuid,
          },
        );

      case 'trip_proximity':
        Get.toNamed(
          AppRoutes.passengerDriverArrival,
          arguments: {
            if (tripUuid    != null) 'tripUuid':    tripUuid,
            if (bookingUuid != null) 'bookingUuid': bookingUuid,
          },
        );

      case 'trip_ended':
        Get.toNamed(
          AppRoutes.passengerTripConfirmation,
          arguments: {
            if (tripUuid    != null) 'tripUuid':    tripUuid,
            if (bookingUuid != null) 'bookingUuid': bookingUuid,
          },
        );

      case 'trip_reminder':
        if (role == 'driver') {
          Get.toNamed(AppRoutes.driverActiveTrip);
        } else {
          Get.toNamed(AppRoutes.passengerReservations);
        }

      // ── Messagerie ───────────────────────────────────────────────────────────
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

      // ── Paiements ────────────────────────────────────────────────────────────
      case 'payment_success':
        if (role == 'driver') {
          Get.toNamed(AppRoutes.driverPaymentHistory);
        } else {
          Get.toNamed(AppRoutes.passengerReservations);
        }

      case 'withdrawal_approved':
      case 'withdrawal_rejected':
        Get.toNamed(AppRoutes.driverWithdraw);

      // ── Remboursements ───────────────────────────────────────────────────────
      case 'refund_approved':
      case 'refund_rejected':
        Get.toNamed(AppRoutes.passengerRefundHistory);

      // ── Avis ─────────────────────────────────────────────────────────────────
      case 'review_new':
        Get.toNamed(AppRoutes.driverReviews);

      case 'review_reply':
        Get.toNamed(AppRoutes.passengerMyReviews);

      // ── Compte ───────────────────────────────────────────────────────────────
      case 'account_verified':
        Get.toNamed(
          role == 'driver' ? AppRoutes.dashboardDriver : AppRoutes.dashboardPassenger,
        );

      case 'account_blocked':
        break;

      // ── Sécurité ─────────────────────────────────────────────────────────────
      case 'sos_triggered':
        Get.toNamed(
          role == 'driver' ? AppRoutes.driverSafetyCenter : AppRoutes.passengerSafetyCenter,
        );

      // ── Notifications générales ──────────────────────────────────────────────
      case 'driver_notifications':
        Get.toNamed(AppRoutes.driverNotifications);

      case 'passenger_notifications':
        Get.toNamed(AppRoutes.passengerNotifications);

      default:
        break;
    }
  }

  // ── Token FCM ─────────────────────────────────────────────────────────────────

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
      await dio.post(
        AppApi.fcmToken,
        data: {'fcm_token': token},
        options: Options(
          validateStatus: (_) => true,
          headers: {'Authorization': 'Bearer $sessionToken'},
        ),
      );
      logger.d('FCM token enregistré: $token');
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

  // ── Helpers payload ───────────────────────────────────────────────────────────

  String _buildPayload(Map<String, dynamic> data) =>
      data.entries.map((e) => '${e.key}=${e.value}').join('&');

  Map<String, dynamic> _parsePayload(String payload) {
    final result = <String, dynamic>{};
    for (final part in payload.split('&')) {
      final idx = part.indexOf('=');
      if (idx > 0) result[part.substring(0, idx)] = part.substring(idx + 1);
    }
    return result;
  }
}
