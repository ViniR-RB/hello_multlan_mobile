import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/box/repositories/box_repository.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_lite_model.dart';

class GetAllBoxesCommand extends BaseCommand<List<BoxLiteModel>, AppException> {
  final BoxRepository _repository;

  GetAllBoxesCommand({
    required BoxRepository repository,
  }) : _repository = repository,
       super(CommandInitial([]));

  Future<void> execute() async {
    setState(CommandLoading());

    final listBoxResult = await _repository.getAllBoxes();

    listBoxResult.when(
      onSuccess: (boxList) {
        setState(CommandSuccess(boxList));
      },
      onFailure: (AppException exception) {
        setState(CommandFailure(exception));
      },
    );
  }

  @override
  void reset() {
    setState(CommandInitial([]));
  }
}
