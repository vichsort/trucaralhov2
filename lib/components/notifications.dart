import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SimpleNotification {
  static Timer? _timer;
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _timeLimit = Duration(hours: 2);

  static Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _plugin.initialize(initializationSettings);

    // Solicitar permissão para notificações (Android 13+)
    await _requestPermissions();

    _initialized = true;
  }

  static Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static void startTimer() {
    _timer?.cancel();

    _timer = Timer(_timeLimit, () {
      _sendNotification();
    });
  }

  static Future<void> _sendNotification() async {
    if (!_initialized) {
      await init();
    }

    await _plugin.show(
      0,
      '🃏 Sentimos sua falta!',
      'Faça como Sr. Carvalho e jogue Trucaralho',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trucaralho',
          'Trucaralho',
          channelDescription: 'Notificações do jogo Trucaralho',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> testNotification() async {
    if (!_initialized) {
      await init();
    }
    await _sendNotification();
  }
}
