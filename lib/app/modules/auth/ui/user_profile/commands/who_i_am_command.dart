import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/auth/models/user_model.dart';
import 'package:hello_multlan/app/modules/auth/repositories/auth_repository.dart';

class WhoIAmCommand extends BaseCommand<UserModel?, AppException> {
  final AuthRepository _authRepository;

  WhoIAmCommand(this._authRepository) : super(CommandInitial(null));

  Future<void> execute() async {
    setState(CommandLoading());

    final result = await _authRepository.whoIAm();

    result.when(
      onSuccess: (user) => setState(CommandSuccess(user)),
      onFailure: (exception) => setState(CommandFailure(exception)),
    );
  }

  @override
  void reset() {
    setState(CommandInitial(null));
  }
}
