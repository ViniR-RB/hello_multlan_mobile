import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

abstract interface class PushNotification {
  Future<void> initialize();
  @protected
  void onMessage(RemoteMessage message);
  @protected
  void onMessageOpenedApp(RemoteMessage message);
}
