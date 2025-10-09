import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/get_boxes_by_filters_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/watch_user_position_command.dart';

class BoxMapController {
  final GetBoxesByFiltersCommand _getBoxesByFiltersCommand;
  final WatchUserPositionCommand _watchUserPositionCommand;

  final MapController flutterMapController = MapController();
  StreamSubscription<MapEvent>? _mapEventSubscription;
  Timer? _debounceTimer;

  BoxMapController({
    required GetBoxesByFiltersCommand getBoxesByFiltersCommand,
    required WatchUserPositionCommand watchUserPositionCommand,
  }) : _getBoxesByFiltersCommand = getBoxesByFiltersCommand,
       _watchUserPositionCommand = watchUserPositionCommand;

  Future<void> watchUserPosition() => _watchUserPositionCommand.execute();

  void startListeningCameraChanges() {
    _mapEventSubscription = flutterMapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(Duration(milliseconds: 500), () {
          _fetchBoxesForCurrentView();
        });
      }
      if (event is MapEventDoubleTapZoomEnd) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(Duration(milliseconds: 500), () {
          _fetchBoxesForCurrentView();
        });
      }
    });
  }

  void fetchInitialBoxes() {
    _fetchBoxesForCurrentView();
  }

  void _fetchBoxesForCurrentView() {
    final bounds = flutterMapController.camera.visibleBounds;
    final latMin = bounds.southWest.latitude;
    final lngMin = bounds.southWest.longitude;
    final latMax = bounds.northEast.latitude;
    final lngMax = bounds.northEast.longitude;

    _getBoxesByFiltersCommand.execute(
      latMin: latMin,
      lngMin: lngMin,
      latMax: latMax,
      lngMax: lngMax,
    );
  }

  void dispose() {
    _mapEventSubscription?.cancel();
    _debounceTimer?.cancel();
  }
}
