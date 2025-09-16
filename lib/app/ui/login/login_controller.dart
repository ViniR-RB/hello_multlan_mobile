import 'package:hello_multlan/app/modules/auth/dtos/credentials.dart';
import 'package:hello_multlan/app/ui/login/command/login_command.dart';

class LoginController {
  final LoginCommand _loginCommand;

  LoginController({required LoginCommand loginCommand})
    : _loginCommand = loginCommand;

  Future<void> login(Credentials credentials) =>
      _loginCommand.execute(credentials);
}
