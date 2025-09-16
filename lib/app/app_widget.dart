import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/data/push_notification/push_notification.dart';
import 'package:hello_multlan/app/core/delegates/lucid_delegate.dart';
import 'package:hello_multlan/app/core/error/global_error_handler.dart';
import 'package:hello_multlan/app/core/theme/app_theme.dart';
import 'package:hello_multlan/l10n/app_localizations.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  FirebaseMessaging firebase = FirebaseMessaging.instance;
  @override
  void initState() {
    GlobalErrorHandler.initialize();
    Modular.get<PushNotification>().initialize();
    Modular.setNavigatorKey(GlobalErrorHandler.navigatorKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Application Name',
      theme: appTheme,
      localizationsDelegates: [
        LucidLocalizationDelegate.delegate,
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.light,
      supportedLocales: [Locale("en"), Locale("pt")],
      routerConfig: Modular.routerConfig,
    );
  }
}
