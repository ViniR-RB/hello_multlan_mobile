import 'package:flutter/material.dart';

class GlobalKeys {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Método para obter o contexto atual se disponível
  static BuildContext? get currentContext => navigatorKey.currentContext;

  // Método para obter o state atual se disponível
  static NavigatorState? get currentState => navigatorKey.currentState;
}
