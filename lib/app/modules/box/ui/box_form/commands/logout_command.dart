import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/auth/repositories/auth_repository.dart';

class LogoutCommand extends BaseCommand<Unit?, AppException> {
  final AuthRepository _authRepository;
  LogoutCommand({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(CommandInitial(null));

  Future<void> execute() async {
    setState(CommandLoading());
    final logoutResult = await _authRepository.logout();
    logoutResult.when(
      onFailure: (exception) => setState(CommandFailure(exception)),
      onSuccess: (unit) => setState(CommandSuccess(unit)),
    );
  }

  @override
  void reset() {
    setState(CommandInitial(null));
  }
}
