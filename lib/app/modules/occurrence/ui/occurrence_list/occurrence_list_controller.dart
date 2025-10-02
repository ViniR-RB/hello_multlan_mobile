import 'package:hello_multlan/app/modules/occurrence/repositories/models/occurence_model.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/command/cancel_occurrence_command.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/command/get_all_occurrence_command.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/command/resolve_occurrence_command.dart';

class OccurrenceListController {
  final GetAllOccurrenceCommand _getAllOccurrenceCommand;
  final CancelOccurrenceCommand _cancelOccurrenceCommand;
  final ResolveOccurrenceCommand _resolveOccurrenceCommand;

  OccurrenceListController({
    required GetAllOccurrenceCommand getAllOccurrenceCommand,
    required CancelOccurrenceCommand cancelOccurrenceCommand,
    required ResolveOccurrenceCommand resolveOccurrenceCommand,
  }) : _getAllOccurrenceCommand = getAllOccurrenceCommand,
       _cancelOccurrenceCommand = cancelOccurrenceCommand,
       _resolveOccurrenceCommand = resolveOccurrenceCommand;

  Future<void> getAllOccurences({
    int take = 10,
    OccurrenceStatus? status,
  }) => _getAllOccurrenceCommand.execute(take: take, status: status);

  Future<void> filterByStatus(OccurrenceStatus? status) =>
      _getAllOccurrenceCommand.execute(status: status, refresh: true);

  Future<void> cancelOccurrence({
    required String occurrenceId,
    required String cancelReason,
  }) => _cancelOccurrenceCommand.execute(
    occurrenceId: occurrenceId,
    cancelReason: cancelReason,
  );

  Future<void> resolveOccurrence({
    required String occurrenceId,
  }) => _resolveOccurrenceCommand.execute(occurrenceId: occurrenceId);
}
