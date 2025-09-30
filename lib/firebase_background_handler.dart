import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Handler para push notifications em background
/// Este handler é executado quando o app está em background ou fechado
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log(
    "Push Notification recebida em background: ${message.notification?.title}",
  );
  log("Push Notification data: ${message.data}");

  // Aqui você pode processar a notificação em background se necessário
  // Por exemplo: salvar dados localmente, fazer requests simples, etc.
  // IMPORTANTE: Não tente navegar ou usar contexto aqui, pois o app está em background
}
