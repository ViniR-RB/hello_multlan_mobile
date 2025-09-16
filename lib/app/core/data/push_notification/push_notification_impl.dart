import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hello_multlan/app/core/config/constants.dart';
import 'package:hello_multlan/app/core/data/local_notifications/local_notification.dart';
import 'package:hello_multlan/app/core/data/local_storage/i_local_storage.service.dart';
import 'package:hello_multlan/app/core/data/push_notification/push_notification.dart';

// Função top-level para background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Push Notification recebida em background: ", error: message.data);
  // Exemplo: mostrar notificação local (se necessário)
  // LocalNotificationImpl.showLocalNotificationStatic(
  //   message.notification?.title ?? "",
  //   message.notification?.body ?? "",
  // );
}

class PushNotificationImpl implements PushNotification {
  final FirebaseMessaging _messaging;
  final LocalNotification _localNotifications;
  final ILocalStorageService _localStorageService;

  PushNotificationImpl({
    required FirebaseMessaging messaging,
    required LocalNotification localNotifications,
    required ILocalStorageService localStorageService,
  }) : _localNotifications = localNotifications,
       _localStorageService = localStorageService,
       _messaging = messaging;

  @override
  Future<void> initialize() async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    await _localStorageService.set(Constants.fcmToken, token ?? "");

    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
  }

  @override
  void onMessage(RemoteMessage message) {
    final notification = message.notification;
    log("Recive Push Notification $notification ");
    if (notification == null) {
      return;
    }
    _localNotifications.showLocalNotification(
      notification.title ?? "",
      notification.body ?? "",
    );
  }

  @override
  void onMessageOpenedApp(RemoteMessage message) {
    final notification = message.notification;
    log("Push Notification aberta pelo usuário: $notification ");
    if (notification == null) {
      return;
    }
    _localNotifications.showLocalNotification(
      notification.title ?? "",
      notification.body ?? "",
    );
  }
}
