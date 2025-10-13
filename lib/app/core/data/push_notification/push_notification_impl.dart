import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hello_multlan/app/core/config/constants.dart';
import 'package:hello_multlan/app/core/data/local_notifications/local_notification.dart';
import 'package:hello_multlan/app/core/data/local_storage/i_local_storage.service.dart';
import 'package:hello_multlan/app/core/data/navigation/navigation_service.dart';
import 'package:hello_multlan/app/core/data/push_notification/push_notification.dart';

class PushNotificationImpl implements PushNotification {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocalNotification _localNotifications;
  final ILocalStorageService _localStorageService;
  final NavigationService _navigationService;

  PushNotificationImpl({
    required LocalNotification localNotifications,
    required ILocalStorageService localStorageService,
    required NavigationService navigationService,
  }) : _localNotifications = localNotifications,
       _localStorageService = localStorageService,
       _navigationService = navigationService;

  @override
  Future<void> initialize() async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    await _localStorageService.set(Constants.fcmToken, token ?? "");

    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);

    // Verificar se o app foi aberto através de uma notificação
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      log(
        "App aberto através de notificação inicial: ${initialMessage.notification}",
      );
      // Navegar para /occurrence após verificar login
      _navigationService.navigateToOccurrenceIfLoggedIn();
    }
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

    // Verificar se o usuário está logado e navegar para /occurrence
    _navigationService.navigateToOccurrenceIfLoggedIn();
  }
}
