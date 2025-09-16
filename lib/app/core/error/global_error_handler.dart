import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GlobalErrorHandler {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void initialize() {
    // Captura erros do Flutter framework
    FlutterError.onError = (FlutterErrorDetails details) {
      log("Flutter Error", error: details.exception, stackTrace: details.stack);
      _showErrorBottomSheet(details.exception.toString());
    };
  }

  static void handleError(Object error, [StackTrace? stackTrace]) {
    log("Global Error", error: error, stackTrace: stackTrace);
    _showErrorBottomSheet(error.toString());
  }

  static void _showErrorBottomSheet(String errorMessage) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => ErrorBottomSheet(errorMessage: errorMessage),
    );
  }
}

class ErrorBottomSheet extends StatelessWidget {
  final String errorMessage;

  const ErrorBottomSheet({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador visual
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Ícone de erro
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),

          // Título
          const Text(
            'Ops! Algo deu errado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Mensagem
          Text(
            'Ocorreu um erro inesperado. Tente novamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Botões
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToSplash();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Tentar Novamente',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          // Espaço para safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _navigateToSplash() {
    // Navega para a splash page e remove todas as rotas anteriores
    Modular.to.pushNamedAndRemoveUntil('/', (route) => false);
  }
}
