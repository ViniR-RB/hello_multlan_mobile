import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/core_module.dart';
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
    i.addLazySingleton(UserLogged.new);
    i.addLazySingleton(LoginCommand.new);
  }

  @override
  void routes(RouteManager r) {}
}
