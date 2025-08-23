import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/ui/splash/command/user_logged.dart';

class SplashController {
  Future<void> userIsLogged() => Modular.get<UserLogged>().execute();
}
