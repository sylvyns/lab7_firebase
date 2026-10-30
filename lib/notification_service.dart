import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Всё, что связано с уведомлениями, собрано в одном классе.
class NotificationService {
  // FCM — получает push-уведомления из Firebase
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Локальные уведомления — показывают уведомление на экране телефона
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static int _id = 0; // у каждого уведомления свой номер

  static Future<void> init() async {
    //  Спрашиваем у пользователя разрешение на уведомления
    await _messaging.requestPermission();

    //  Настраиваем локальные уведомления (иконка = иконка приложения)
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _local.initialize(settings: settings);

    // Получаем FCM-токен — это "адрес" нашего телефона для push
    final token = await _messaging.getToken();
    debugPrint('FCM TOKEN: $token');

    // Если push пришёл, когда приложение открыто — показываем его сами
    //    (когда приложение свёрнуто, Android показывает push автоматически)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        show(
          title: notification.title ?? 'Новое уведомление',
          body: notification.body ?? '',
        );
      }
    });
  }

  /// Показать уведомление на телефоне
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'main_channel', // id канала
        'Основные уведомления', // название канала в настройках телефона
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _local.show(
      id: _id++,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
