import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/models/occurence_model.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/occurrence_repository.dart';

class GetAllOccurrenceCommand
    extends BaseCommand<List<OccurrenceModel>, AppException> {
  final OccurrenceRepository _repository;

  GetAllOccurrenceCommand({required OccurrenceRepository repository})
    : _repository = repository,

      super(CommandInitial([]));

  @override
  void reset() {
    setState(CommandInitial([]));
  }

  Future<void> execute() async {
    final occurrenceListResult = await _repository.getAllOccurrences();

    occurrenceListResult.when(
      onSuccess: (occurrenceListResult) {
        setState(CommandSuccess(occurrenceListResult));
      },
      onFailure: (error) {
        setState(CommandFailure(error));
      },
    );
  }
}
