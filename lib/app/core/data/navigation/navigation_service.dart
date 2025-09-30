import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';

abstract interface class NavigationService {
  /// Navega para a rota de ocorrência após verificar se o usuário está logado
  Future<void> navigateToOccurrenceIfLoggedIn();

  /// Verifica se o usuário está logado
  AsyncResult<AppException, bool> isUserLoggedIn();
}
