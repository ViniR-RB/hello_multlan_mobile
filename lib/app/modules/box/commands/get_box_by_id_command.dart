import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/box/repositories/box_repository.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_model.dart';

class GetBoxByIdCommand extends BaseCommand<BoxModel?, AppException> {
  final BoxRepository _boxRepository;

  GetBoxByIdCommand({required BoxRepository boxRepository})
    : _boxRepository = boxRepository,
      super(CommandInitial(null));

  Future<void> execute(String id) async {
    setState(CommandLoading());

    final getBoxResult = await _boxRepository.getBoxById(id);

    getBoxResult.when(
      onSuccess: (box) => setState(CommandSuccess(box)),
      onFailure: (error) => setState(CommandFailure(error)),
    );
  }

  @override
  void reset() {
    setState(CommandInitial(null));
  }
}
