import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hello_multlan/app/core/data/local_notifications/local_notification.dart';

class LocalNotificationImpl implements LocalNotification {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> setupLocalNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  @override
  void showLocalNotification(String title, String body) {
    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'Main Channel',
          channelDescription: 'Canal principal para notificações',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          showWhen: false,
        ),
      ),
    );
  }
}
