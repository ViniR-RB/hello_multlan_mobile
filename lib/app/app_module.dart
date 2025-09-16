import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/core_module.dart';
import 'package:hello_multlan/app/modules/auth/auth_module.dart';
import 'package:hello_multlan/app/modules/box/box_module.dart';
import 'package:hello_multlan/app/modules/occurrence/occurrence_module.dart';
import 'package:hello_multlan/app/ui/error/error_page.dart';
import 'package:hello_multlan/app/ui/login/command/login_command.dart';
import 'package:hello_multlan/app/ui/login/login_controller.dart';
import 'package:hello_multlan/app/ui/login/login_page.dart';
import 'package:hello_multlan/app/ui/splash/command/user_logged.dart';
import 'package:hello_multlan/app/ui/splash/splash_controller.dart';
import 'package:hello_multlan/app/ui/splash/splash_page.dart';

class AppModule extends Module {
  @override
  List<Module> get imports => [CoreModule(), AuthModule()];

  @override
  void binds(Injector i) {
    i.addSingleton(SplashController.new);
    i.addSingleton(LoginController.new);
  }

  @override
  void exportedBinds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child(
      "/",
      child: (_) => SplashPage(
        controller: Modular.get<SplashController>(),
        userLogged: Modular.get<UserLogged>(),
      ),
    );
    r.child(
      "/login",
      child: (_) => LoginPage(
        controller: Modular.get<LoginController>(),
        loginCommand: Modular.get<LoginCommand>(),
      ),
    );
    r.child(
      '/error',
      child: (_) {
        final errorMsg = Modular.args.data as String?;
        return ErrorPage(errorMsg: errorMsg ?? 'Erro desconhecido');
      },
    );
    r.module("/box", module: BoxModule());
    r.module("/occurrence", module: OccurrenceModule());
  }
}
