import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/occurrence_repository.dart';

class ResolveOccurrenceCommand extends BaseCommand<Unit, AppException> {
  final OccurrenceRepository _repository;

  ResolveOccurrenceCommand({required OccurrenceRepository repository})
    : _repository = repository,
      super(CommandInitial(unit));

  @override
  void reset() {
    setState(CommandInitial(unit));
  }

  Future<void> execute({
    required String occurrenceId,
  }) async {
    setState(CommandLoading());

    final result = await _repository.resolveOccurrence(
      occurrenceId: occurrenceId,
    );

    result.when(
      onSuccess: (unit) {
        setState(CommandSuccess(unit));
      },
      onFailure: (error) {
        setState(CommandFailure(error));
      },
    );
  }
}
