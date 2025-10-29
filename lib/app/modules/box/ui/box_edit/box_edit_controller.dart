import 'package:flutter/widgets.dart';
import 'package:hello_multlan/app/modules/box/commands/get_box_by_id_command.dart';
import 'package:hello_multlan/app/modules/box/dto/edit_box_dto.dart';
import 'package:hello_multlan/app/modules/box/ui/box_edit/commands/update_box_data_command.dart';

class BoxEditController {
  final UpdateBoxDataCommand _updateBoxCommand;
  final GetBoxByIdCommand _getBoxByIdCommand;
  final ValueNotifier<List<bool>> selectedGps = ValueNotifier([true, false]);

  BoxEditController({
    required UpdateBoxDataCommand updateBoxCommand,
    required GetBoxByIdCommand getBoxByIdCommand,
  }) : _updateBoxCommand = updateBoxCommand,
       _getBoxByIdCommand = getBoxByIdCommand;

  Future<void> loadBox(String id) => _getBoxByIdCommand.execute(id);

  Future<void> updateBox(EditBoxDto box) => _updateBoxCommand.execute(box);

  void dispose() {
    selectedGps.dispose();
    _updateBoxCommand.dispose();
    _getBoxByIdCommand.dispose();
  }
}
