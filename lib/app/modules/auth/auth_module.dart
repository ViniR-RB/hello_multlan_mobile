import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/core_module.dart';
import 'package:hello_multlan/app/core/data/rest_client/rest_client.dart';
import 'package:hello_multlan/app/modules/auth/gateway/auth_gateway.dart';
import 'package:hello_multlan/app/modules/auth/repositories/auth_repository.dart';
import 'package:hello_multlan/app/modules/auth/repositories/auth_repository_impl.dart';
import 'package:hello_multlan/app/ui/login/command/login_command.dart';
import 'package:hello_multlan/app/ui/splash/command/user_logged.dart';

class AuthModule extends Module {
  @override
  List<Module> get imports => [
    CoreModule(),
  ];

  @override
  void binds(Injector i) {}

  @override
  void exportedBinds(Injector i) {
    i.addLazySingleton<AuthRepository>(AuthRepositoryImpl.new);
    i.addLazySingleton(() => AuthGateway(i.get<RestClient>()));
    i.addLazySingleton(UserLogged.new);
    i.addLazySingleton(LoginCommand.new);
  }

  @override
  void routes(RouteManager r) {}
}
