import 'package:hello_multlan/app/modules/box/ui/box_map_detail/commands/get_box_by_id_command.dart';

class BoxMapDetailController {
  final GetBoxByIdCommand getBoxByIdCommand;

  BoxMapDetailController({required this.getBoxByIdCommand});

  Future<void> getBoxById(String id) async {
    await getBoxByIdCommand.execute(id);
  }
}
