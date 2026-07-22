import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../utils/logger.dart';
import '../../../routes/app_routes.dart';

// Gestionnaire de messages en arrière-plan (doit être top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _PushNotificationService._showLocalNotificationStatic(message);
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'covoiturage_benin_high';
  static const _channelName = 'Covoiturage Bénin';
  static const _channelDesc = 'Réservations, trajets et messages importants';

  // Canal static pour le handler background
  static final _staticLocalNotifications = FlutterLocalNotificationsPlugin();
  static bool _staticInitialized = false;

  Future<void> initialize() async {
    await _createAndroidChannel();
    await _initLocalNotifications();
    await _requestPermission();
    _listenForeground();
    _listenOnTap();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _logToken();
  }

  // ── Canal Android haute importance avec son ────────────────────────────────

  Future<void> _createAndroidChannel() async {
    if (!Platform.isAndroid) return;
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ── Initialisation du plugin local ────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    // Initialise la version static pour le background handler
    if (!_staticInitialized) {
      await _staticLocalNotifications.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      _staticInitialized = true;
    }
  }

  // ── Permission (Android 13+) ───────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: false,
    );
    logger.d('FCM permission: ${settings.authorizationStatus}');
  }

  // ── Écoute messages premier plan ──────────────────────────────────────────

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      logger.d('FCM foreground: ${message.notification?.title}');
      showLocalNotification(message);
    });
  }

  // ── Écoute tap sur notification (app en arrière-plan, pas fermée) ─────────

  void _listenOnTap() {
    FirebaseMessaging.onMessageOpenedApp.listen(_navigateFromMessage);
    // App fermée → notification tap
    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          _navigateFromMessage(message);
        });
      }
    });
  }

  // ── Affichage notification locale ─────────────────────────────────────────

  void showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
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
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _buildPayload(message.data),
    );
  }

  // Version statique pour le background handler
  static void _showLocalNotificationStatic(RemoteMessage message) {
    if (!_staticInitialized) return;
    final notification = message.notification;
    if (notification == null) return;

    _staticLocalNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
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

  // ── Navigation depuis tap notification ────────────────────────────────────

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    final data = _parsePayload(payload);
    _navigate(data);
  }

  void _navigateFromMessage(RemoteMessage message) {
    _navigate(message.data);
  }

  void _navigate(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    switch (type) {
      case 'reservation_new':
      case 'reservation_accepted':
      case 'reservation_rejected':
        final role = data['role'] as String? ?? '';
        if (role == 'driver') {
          Get.toNamed(AppRoutes.driverReservations);
        } else {
          Get.toNamed(AppRoutes.passengerReservations);
        }
      case 'trip_started':
      case 'trip_proximity':
        Get.toNamed(AppRoutes.passengerLiveTracking);
      case 'message_new':
        final role = data['role'] as String? ?? '';
        final conversationUuid = data['conversation_uuid'] as String?;
        if (role == 'driver') {
          Get.toNamed(AppRoutes.driverMessages);
        } else {
          if (conversationUuid != null) {
            Get.toNamed(
              AppRoutes.passengerMessageDetail,
              arguments: {'uuid': conversationUuid},
            );
          } else {
            Get.toNamed(AppRoutes.passengerMessages);
          }
        }
      case 'driver_notifications':
        Get.toNamed(AppRoutes.driverNotifications);
      case 'passenger_notifications':
        Get.toNamed(AppRoutes.passengerNotifications);
      default:
        break;
    }
  }

  // ── Token FCM ─────────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      logger.e('FCM getToken: $e');
      return null;
    }
  }

  void _logToken() {
    _fcm.getToken().then((t) => logger.d('FCM Token: $t'));
    _fcm.onTokenRefresh.listen((t) => logger.d('FCM Token refreshed: $t'));
  }

  // ── Helpers payload ───────────────────────────────────────────────────────

  String _buildPayload(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  Map<String, dynamic> _parsePayload(String payload) {
    final result = <String, dynamic>{};
    for (final part in payload.split('&')) {
      final idx = part.indexOf('=');
      if (idx > 0) result[part.substring(0, idx)] = part.substring(idx + 1);
    }
    return result;
  }
}
