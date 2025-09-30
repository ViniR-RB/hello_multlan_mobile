import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/error/global_error_handler.dart';
import 'package:hello_multlan/firebase_background_handler.dart';
import 'package:hello_multlan/firebase_options.dart';

import './app/app_module.dart';
import './app/app_widget.dart';

Future<void> main() async {
  return runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Inicializar Firebase primeiro
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Registrar o background handler APÓS inicializar o Firebase
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      runApp(ModularApp(module: AppModule(), child: const AppWidget()));
    },
    (error, stackTrace) {
      log("Unexpected Error", error: error, stackTrace: stackTrace);
      GlobalErrorHandler.handleError(error, stackTrace);
    },
  );
}
