import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:hello_multlan/app/modules/box/commands/get_box_by_id_command.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_zone_enum.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/get_boxes_by_filters_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/watch_user_position_command.dart';
import 'package:latlong2/latlong.dart';

class BoxMapController {
  final GetBoxesByFiltersCommand _getBoxesByFiltersCommand;
  final WatchUserPositionCommand _watchUserPositionCommand;
  final GetBoxByIdCommand _getBoxByIdCommand;

  final MapController flutterMapController = MapController();
  StreamSubscription<MapEvent>? _mapEventSubscription;
  Timer? _debounceTimer;

  BoxMapController({
    required GetBoxesByFiltersCommand getBoxesByFiltersCommand,
    required WatchUserPositionCommand watchUserPositionCommand,
    required GetBoxByIdCommand getBoxByIdCommand,
  }) : _getBoxesByFiltersCommand = getBoxesByFiltersCommand,
       _watchUserPositionCommand = watchUserPositionCommand,
       _getBoxByIdCommand = getBoxByIdCommand;

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

  void setBoxZone(BoxZoneEnum? zone) {
    _getBoxesByFiltersCommand.setBoxZone(zone);
    _fetchBoxesForCurrentView(); // Refetch with new zone
  }

  BoxZoneEnum? get currentBoxZone => _getBoxesByFiltersCommand.currentBoxZone;
  GetBoxByIdCommand get getBoxByIdCommand => _getBoxByIdCommand;

  Future<void> fetchBoxById(String boxId) async {
    await _getBoxByIdCommand.execute(boxId);
  }

  void navigateToBoxCoordinates(double latitude, double longitude) {
    flutterMapController.move(
      LatLng(latitude, longitude),
      15.0, // zoom level
    );
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
