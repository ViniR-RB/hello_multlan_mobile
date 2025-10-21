import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/auth/dtos/reset_password_dto.dart';
import 'package:hello_multlan/app/modules/auth/repositories/auth_repository.dart';

class ResetPasswordCommand extends BaseCommand<Unit, AppException> {
  final AuthRepository _authRepository;

  ResetPasswordCommand(this._authRepository) : super(CommandInitial(unit));

  Future<void> execute(ResetPasswordDto dto) async {
    setState(CommandLoading());

    final result = await _authRepository.resetPassword(dto);

    result.when(
      onSuccess: (unit) => setState(CommandSuccess(unit)),
      onFailure: (exception) => setState(CommandFailure(exception)),
    );
  }

  @override
  void reset() {
    setState(CommandInitial(unit));
  }
}
