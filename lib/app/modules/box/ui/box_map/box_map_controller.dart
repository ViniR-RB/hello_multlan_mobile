import 'package:flutter_map/flutter_map.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/get_all_boxes_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/watch_user_position_command.dart';

class BoxMapController {
  final GetAllBoxesCommand _getAllBoxesCommand;
  final WatchUserPositionCommand _watchUserPositionCommand;

  final MapController flutterMapController = MapController();

  BoxMapController({
    required GetAllBoxesCommand getAllBoxesCommand,
    required WatchUserPositionCommand watchUserPositionCommand,
  }) : _getAllBoxesCommand = getAllBoxesCommand,
       _watchUserPositionCommand = watchUserPositionCommand;

  Future<void> getAllBoxes() => _getAllBoxesCommand.execute();

  Future<void> watchUserPosition() => _watchUserPositionCommand.execute();
}
