import 'package:hello_multlan/app/modules/box/ui/box_form/commands/logout_command.dart';

class BoxHubController {
  final LogoutCommand _logoutCommand;
  BoxHubController({required LogoutCommand logoutCommand})
    : _logoutCommand = logoutCommand;

  Future<void> logout() async {
    await _logoutCommand.execute();
  }

  void dipose() {
    _logoutCommand.dispose();
  }
}
