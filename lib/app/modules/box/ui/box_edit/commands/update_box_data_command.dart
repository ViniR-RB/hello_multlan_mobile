import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/box/dto/edit_box_dto.dart';
import 'package:hello_multlan/app/modules/box/repositories/box_repository.dart';

class UpdateBoxDataCommand extends BaseCommand<Unit?, AppException> {
  final BoxRepository _boxRepository;

  UpdateBoxDataCommand({required BoxRepository boxRepository})
    : _boxRepository = boxRepository,
      super(CommandInitial(null));

  Future<void> execute(EditBoxDto box) async {
    setState(CommandLoading());

    final updateBoxResult = await _boxRepository.updateBox(box);

    updateBoxResult.when(
      onSuccess: (unit) => setState(CommandSuccess(unit)),
      onFailure: (error) => setState(CommandFailure(error)),
    );
  }

  @override
  void reset() {
    setState(CommandInitial(null));
  }
}




