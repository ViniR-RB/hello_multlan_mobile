import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/data/navigation/navigation_service.dart';
import 'package:hello_multlan/app/core/either/either.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/core/navigation/global_keys.dart';
import 'package:hello_multlan/app/modules/auth/repositories/auth_repository.dart';

class NavigationServiceImpl implements NavigationService {
  static GlobalKey<NavigatorState> get navigatorKey => GlobalKeys.navigatorKey;

  final AuthRepository _authRepository;

  NavigationServiceImpl({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  /// Método estático para acessar o NavigatorKey globalmente
  static GlobalKey<NavigatorState> get globalNavigatorKey => navigatorKey;

  @override
  Future<void> navigateToOccurrenceIfLoggedIn() async {
    log(
      "NavigationService: Verificando se usuário está logado antes de navegar para /occurrence",
    );

    final isLoggedResult = await isUserLoggedIn();

    isLoggedResult.when(
      onSuccess: (isLogged) {
        if (isLogged) {
          log(
            "NavigationService: Usuário está logado, navegando para /occurrence",
          );
          _navigateToOccurrence();
        } else {
          log(
            "NavigationService: Usuário não está logado, navegando para /login",
          );
          _navigateToLogin();
        }
      },
      onFailure: (exception) {
        log("NavigationService: Erro ao verificar login", error: exception);
        // Em caso de erro, navega para login por segurança
        _navigateToLogin();
      },
    );
  }

  @override
  AsyncResult<AppException, bool> isUserLoggedIn() async {
    return await _authRepository.isLogged().flatMap((logged) async {
      if (logged) {
        // Se está logado, verifica se o token ainda é válido
        final whoIAm = await _authRepository.whoIAm();
        return whoIAm.map((_) => true);
      } else {
        return Success(false);
      }
    });
  }

  void _navigateToOccurrence() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Primeiro limpa todas as rotas e vai para /box
      Modular.to.pushNamedAndRemoveUntil('/box', (route) => false);
      // Depois navega para /occurrence, mantendo /box no histórico
      Modular.to.pushNamed('/occurrence');
    } else {
      log("NavigationService: Context não disponível para navegação");
    }
  }

  void _navigateToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Modular.to.pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      log("NavigationService: Context não disponível para navegação");
    }
  }
}
