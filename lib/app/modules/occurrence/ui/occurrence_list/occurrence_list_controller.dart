import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/command/get_all_occurrence_command.dart';

class OccurrenceListController {
  final GetAllOccurrenceCommand _getAllOccurrenceCommand;

  OccurrenceListController({
    required GetAllOccurrenceCommand getAllOccurrenceCommand,
  }) : _getAllOccurrenceCommand = getAllOccurrenceCommand;

  Future<void> getAllOccurences({
    int take = 10,
  }) => _getAllOccurrenceCommand.execute(take: take);
}
