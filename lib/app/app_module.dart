import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/modules/home/home_page.dart';

class AppModule extends Module {
  @override
  List<Module> get imports => const [];

  @override
  void binds(Injector i) {}
  @override
  void exportedBinds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child("/", child: (_) => HomePage());
  }
}
