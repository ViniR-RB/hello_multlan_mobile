import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/core_module.dart';
import 'package:hello_multlan/app/modules/auth/auth_module.dart';
import 'package:hello_multlan/app/ui/splash/command/user_logged.dart';
import 'package:hello_multlan/app/ui/splash/splash_controller.dart';
import 'package:hello_multlan/app/ui/splash/splash_page.dart';

class AppModule extends Module {
  @override
  List<Module> get imports => [CoreModule(), AuthModule()];

  @override
  void binds(Injector i) {
    i.addSingleton(SplashController.new);
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
  }
}
