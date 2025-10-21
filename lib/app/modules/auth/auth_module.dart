import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/core_module.dart';
import 'package:hello_multlan/app/modules/auth/ui/user_profile/commands/reset_password_command.dart';
import 'package:hello_multlan/app/modules/auth/ui/user_profile/commands/who_i_am_command.dart';
import 'package:hello_multlan/app/modules/auth/ui/user_profile/user_profile_controller.dart';
import 'package:hello_multlan/app/modules/auth/ui/user_profile/user_profile_page.dart';
import 'package:hello_multlan/app/ui/login/command/login_command.dart';
import 'package:hello_multlan/app/ui/splash/command/user_logged.dart';

class AuthModule extends Module {
  @override
  List<Module> get imports => [
    CoreModule(),
  ];

  @override
  void binds(Injector i) {
    // Commands
    i.addLazySingleton(ResetPasswordCommand.new);
    i.addLazySingleton(WhoIAmCommand.new);

    // Controller
    i.addLazySingleton(UserProfileController.new);
  }

  @override
  void exportedBinds(Injector i) {
    i.addLazySingleton(UserLogged.new);
    i.addLazySingleton(LoginCommand.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/profile',
      child: (context) => UserProfilePage(
        controller: Modular.get<UserProfileController>(),
        resetPasswordCommand: Modular.get<ResetPasswordCommand>(),
        whoIAmCommand: Modular.get<WhoIAmCommand>(),
      ),
    );
  }
}
