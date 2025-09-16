import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/box/dto/create_box_dto.dart';
import 'package:hello_multlan/app/modules/box/repositories/box_repository.dart';

class CreateBoxDataCommand extends BaseCommand<Unit?, AppException> {
  final BoxRepository _boxRepository;

  CreateBoxDataCommand({required BoxRepository boxRepository})
    : _boxRepository = boxRepository,
      super(CommandInitial(null));

  Future<void> execute(CreateBoxDto box) async {
    setState(CommandLoading());

    final createBoxResult = await _boxRepository.createBox(box);

    createBoxResult.when(
      onSuccess: (unit) => setState(CommandSuccess(unit)),
      onFailure: (error) => setState(CommandFailure(error)),
    );
  }

  @override
  void reset() {
    setState(CommandInitial(null));
  }
}
