import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifHelper {
  LocalNotifHelper._();
  static final LocalNotifHelper i = LocalNotifHelper._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'tracking_channel',
      'Suivi de trajet',
      channelDescription: 'Notifications de suivi en temps réel',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }
}

// IDs de notification fixes (un par type → se déclenche une seule fois)
class TrackingNotifId {
  static const started    = 1001;
  static const approaching = 1002;
  static const nearDest   = 1003;
  static const completed  = 1004;
}
