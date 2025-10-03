import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hello_multlan/app/core/extensions/error_translator.dart';
import 'package:hello_multlan/app/core/extensions/loader_message.dart';
import 'package:hello_multlan/app/core/extensions/theme_extension.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/box_map_controller.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/get_all_boxes_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/watch_user_position_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/widgets/box_detail_button_sheet.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/widgets/user_location_widget.dart';
import 'package:hello_multlan/gen/assets.gen.dart';
import 'package:latlong2/latlong.dart';

class BoxMapPage extends StatefulWidget {
  final BoxMapController controller;
  final GetAllBoxesCommand getAllBoxesCommand;
  final WatchUserPositionCommand watchUserPositionCommand;
  const BoxMapPage({
    super.key,
    required this.controller,
    required this.getAllBoxesCommand,
    required this.watchUserPositionCommand,
  });

  @override
  State<BoxMapPage> createState() => _BoxMapPageState();
}

class _BoxMapPageState extends State<BoxMapPage>
    with ErrorTranslator, LoaderMessageMixin {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.getAllBoxes();
      widget.controller.watchUserPosition();
      widget.watchUserPositionCommand.addListener(_listerUserPosition);
      widget.getAllBoxesCommand.addListener(_getAllBoxesListener);
    });
    super.initState();
  }

  _listerUserPosition() {
    switch (widget.watchUserPositionCommand.state) {
      case CommandFailure(exception: final exception):
        notifier.showMessage(
          translateError(context, exception.code),
          SnackType.error,
        );
      case CommandLoading() || CommandInitial() || CommandSuccess():
        break;
    }
  }

  _getAllBoxesListener() {
    if (widget.getAllBoxesCommand.state is CommandLoading) {
      notifier.showLoader();
    }
    if (widget.getAllBoxesCommand.state is CommandSuccess) {
      notifier.hideLoader();
    }
    if (widget.getAllBoxesCommand.state case CommandFailure(
      exception: final exception,
    )) {
      notifier.hideLoader();

      notifier.showMessage(
        translateError(context, exception.code),
        SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Box Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              widget.controller.getAllBoxes();
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          FlutterMap(
            mapController: widget.controller.flutterMapController,

            options: MapOptions(
              initialCenter: const LatLng(-5.1750424, -42.7906436),
              keepAlive: true,
              initialZoom: 10,
              onMapReady: () => widget
                  .controller
                  .flutterMapController
                  .mapEventStream
                  .listen((event) {
                    // Handle map events here
                  }),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                maxZoom: 19,
                errorTileCallback: (tile, error, stackTrace) {
                  if (error is SocketException) {
                    notifier.showMessage(
                      translateError(context, "mapNotLoading"),
                      SnackType.error,
                    );
                    return;
                  }
                  notifier.showMessage(
                    translateError(context, "unknownError"),
                    SnackType.error,
                  );
                },
                userAgentPackageName: "dev.vini.br.hello_multlan",
              ),
              ListenableBuilder(
                listenable: widget.getAllBoxesCommand,
                builder: (context, child) {
                  return switch (widget.getAllBoxesCommand.state) {
                    CommandSuccess(value: final boxList) => MarkerLayer(
                      markers: boxList
                          .map(
                            (box) => Marker(
                              alignment: Alignment.center,
                              point: LatLng(
                                box.latitude.toDouble(),
                                box.longitude.toDouble(),
                              ),
                              child: InkWell(
                                onTap: () =>
                                    BoxDetailsBottomSheet.showBottomSheetBoxById(
                                      box.id,
                                      context,
                                    ),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  direction: Axis.vertical,
                                  children: [
                                    Assets.images.markerIcon.image(),
                                    Text(
                                      box.label,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      softWrap: true,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colors.primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    _ => SizedBox.shrink(),
                  };
                },
              ),
              ListenableBuilder(
                listenable: widget.watchUserPositionCommand,
                builder: (context, child) {
                  return switch (widget.watchUserPositionCommand.state) {
                    CommandSuccess(value: final position!) => MarkerLayer(
                      markers: [
                        Marker(
                          height: 24,
                          width: 24,
                          alignment: Alignment.center,
                          point: LatLng(
                            position.latitude,
                            position.longitude,
                          ),
                          child: UserLocationWidget(),
                        ),
                      ],
                    ),
                    _ => SizedBox.shrink(),
                  };
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
