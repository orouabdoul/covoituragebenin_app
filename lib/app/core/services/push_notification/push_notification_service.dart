import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../constants/app_api.dart';
import '../../controller/user_controller.dart';
import '../../utils/app_dio.dart';
import '../../utils/logger.dart';
import '../../../routes/app_routes.dart';

// Gestionnaire de messages en arrière-plan (doit être top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  PushNotificationService._showLocalNotificationStatic(message);
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
    final type        = data['type'] as String? ?? '';
    final role        = data['role'] as String? ?? '';
    final tripUuid    = data['trip_uuid']         as String?;
    final bookingUuid = data['booking_uuid']       as String?;
    final convUuid    = data['conversation_uuid']  as String?;

    switch (type) {

      // ── Réservations ────────────────────────────────────────────────────────
      case 'reservation_new':
        // Passager a réservé → conducteur voit ses réservations
        Get.toNamed(AppRoutes.driverReservations);

      case 'reservation_accepted':
        // Conducteur a accepté → passager attend l'approbation ou suit le statut
        Get.toNamed(
          AppRoutes.passengerWaitingApproval,
          arguments: bookingUuid != null ? {'booking_uuid': bookingUuid} : null,
        );

      case 'reservation_rejected':
        // Conducteur a rejeté → passager voit ses réservations
        Get.toNamed(AppRoutes.passengerReservations);

      case 'booking_cancelled':
        // Passager a annulé → conducteur voit ses réservations
        Get.toNamed(AppRoutes.driverReservations);

      case 'trip_cancelled':
        // Conducteur a annulé le trajet → passager voit ses réservations
        Get.toNamed(AppRoutes.passengerReservations);

      // ── Trajet en cours ─────────────────────────────────────────────────────
      case 'trip_started':
        // Conducteur démarre → passager va sur le suivi en direct
        Get.toNamed(
          AppRoutes.passengerLiveTracking,
          arguments: {
            if (tripUuid    != null) 'tripUuid':    tripUuid,
            if (bookingUuid != null) 'bookingUuid': bookingUuid,
          },
        );

      case 'trip_proximity':
        // Conducteur à 1 km → passager va sur l'écran d'arrivée du conducteur
        Get.toNamed(
          AppRoutes.passengerDriverArrival,
          arguments: {
            if (tripUuid    != null) 'tripUuid':    tripUuid,
            if (bookingUuid != null) 'bookingUuid': bookingUuid,
          },
        );

      case 'trip_ended':
        // Trajet terminé → passager confirme la fin du trajet
        Get.toNamed(
          AppRoutes.passengerTripConfirmation,
          arguments: {
            if (tripUuid    != null) 'tripUuid':    tripUuid,
            if (bookingUuid != null) 'bookingUuid': bookingUuid,
          },
        );

      case 'trip_reminder':
        // Rappel avant départ → conducteur voit son trajet actif
        if (role == 'driver') {
          Get.toNamed(AppRoutes.driverActiveTrip);
        } else {
          Get.toNamed(AppRoutes.passengerReservations);
        }

      // ── Messagerie ──────────────────────────────────────────────────────────
      case 'message_new':
        if (role == 'driver') {
          if (convUuid != null) {
            Get.toNamed(
              AppRoutes.driverMessageDetail,
              arguments: {'uuid': convUuid},
            );
          } else {
            Get.toNamed(AppRoutes.driverMessages);
          }
        } else {
          if (convUuid != null) {
            Get.toNamed(
              AppRoutes.passengerMessageDetail,
              arguments: {'uuid': convUuid},
            );
          } else {
            Get.toNamed(AppRoutes.passengerMessages);
          }
        }

      // ── Paiements ───────────────────────────────────────────────────────────
      case 'payment_success':
        if (role == 'driver') {
          Get.toNamed(AppRoutes.driverPaymentHistory);
        } else {
          Get.toNamed(AppRoutes.passengerReservations);
        }

      case 'withdrawal_approved':
      case 'withdrawal_rejected':
        Get.toNamed(AppRoutes.driverWithdraw);

      // ── Remboursements ──────────────────────────────────────────────────────
      case 'refund_approved':
      case 'refund_rejected':
        Get.toNamed(AppRoutes.passengerRefundHistory);

      // ── Avis ────────────────────────────────────────────────────────────────
      case 'review_new':
        // Passager a laissé un avis → conducteur voit ses avis
        Get.toNamed(AppRoutes.driverReviews);

      case 'review_reply':
        // Conducteur a répondu → passager voit ses avis
        Get.toNamed(AppRoutes.passengerMyReviews);

      // ── Compte ──────────────────────────────────────────────────────────────
      case 'account_verified':
        if (role == 'driver') {
          Get.toNamed(AppRoutes.dashboardDriver);
        } else {
          Get.toNamed(AppRoutes.dashboardPassenger);
        }

      case 'account_blocked':
        // Pas de navigation — l'app redirigera vers login au prochain lancement
        break;

      // ── Sécurité ────────────────────────────────────────────────────────────
      case 'sos_triggered':
        if (role == 'driver') {
          Get.toNamed(AppRoutes.driverSafetyCenter);
        } else {
          Get.toNamed(AppRoutes.passengerSafetyCenter);
        }

      // ── Notifications générales ─────────────────────────────────────────────
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

  /// Envoie le token FCM au backend Laravel.
  /// À appeler après chaque connexion réussie.
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
    // Re-enregistre automatiquement si le token est renouvelé par Firebase
    _fcm.onTokenRefresh.listen((t) {
      logger.d('FCM Token refreshed: $t');
      registerFcmToken();
    });
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
