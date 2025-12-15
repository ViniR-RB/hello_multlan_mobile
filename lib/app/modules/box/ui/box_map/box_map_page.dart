import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/extensions/error_translator.dart';
import 'package:hello_multlan/app/core/extensions/loader_message.dart';
import 'package:hello_multlan/app/core/extensions/theme_extension.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/core/widgets/custom_app_bar_primary.dart';
import 'package:hello_multlan/app/modules/box/commands/get_box_by_id_command.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_zone_enum.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/box_map_controller.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/get_boxes_by_filters_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/watch_user_position_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/widgets/box_detail_button_sheet.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/widgets/user_location_widget.dart';
import 'package:hello_multlan/gen/assets.gen.dart';
import 'package:latlong2/latlong.dart';

class BoxMapPage extends StatefulWidget {
  final BoxMapController controller;
  final GetBoxesByFiltersCommand getBoxesByFiltersCommand;
  final WatchUserPositionCommand watchUserPositionCommand;
  final String? boxId;
  const BoxMapPage({
    super.key,
    required this.controller,
    required this.getBoxesByFiltersCommand,
    required this.watchUserPositionCommand,
    this.boxId,
  });

  @override
  State<BoxMapPage> createState() => _BoxMapPageState();
}

class _BoxMapPageState extends State<BoxMapPage>
    with ErrorTranslator, LoaderMessageMixin {
  late final GetBoxByIdCommand _getBoxByIdCommand;

  @override
  void initState() {
    _getBoxByIdCommand = widget.controller.getBoxByIdCommand;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.watchUserPosition();
      widget.controller.startListeningCameraChanges();
      widget.controller.fetchInitialBoxes();
      widget.watchUserPositionCommand.addListener(_listerUserPosition);
      widget.getBoxesByFiltersCommand.addListener(_getBoxesByFiltersListener);
      _getBoxByIdCommand.addListener(_getBoxByIdListener);

      // Se tem boxId, buscar e navegar para a box
      if (widget.boxId != null && widget.boxId!.isNotEmpty) {
        _handleBoxIdNavigation(widget.boxId!);
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(BoxMapPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se o boxId mudou, navegar para a nova box
    if (widget.boxId != null && widget.boxId != oldWidget.boxId) {
      _handleBoxIdNavigation(widget.boxId!);
    }
  }

  @override
  void dispose() {
    _getBoxByIdCommand.removeListener(_getBoxByIdListener);
    widget.controller.dispose();
    super.dispose();
  }

  void _handleBoxIdNavigation(String boxId) async {
    await widget.controller.fetchBoxById(boxId);
  }

  void _getBoxByIdListener() {
    switch (_getBoxByIdCommand.state) {
      case CommandSuccess(value: final box):
        if (box != null) {
          // Navegar para as coordenadas da box
          widget.controller.navigateToBoxCoordinates(
            box.latitude.toDouble(),
            box.longitude.toDouble(),
          );

          // Abrir o bottom sheet com os detalhes da box
          WidgetsBinding.instance.addPostFrameCallback((_) {
            BoxDetailsBottomSheet.showBottomSheetBoxById(
              box.id,
              context,
            );
          });
        } else {
          notifier.showMessage(
            'Box não encontrada',
            SnackType.error,
          );
        }
        break;
      case CommandFailure(exception: final exception):
        notifier.showMessage(
          translateError(context, exception.code),
          SnackType.error,
        );
        break;
      case CommandLoading() || CommandInitial():
        break;
    }
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

  _getBoxesByFiltersListener() {
    if (widget.getBoxesByFiltersCommand.state is CommandLoading) {
      notifier.showLoader();
    }
    if (widget.getBoxesByFiltersCommand.state is CommandSuccess) {
      notifier.hideLoader();
    }
    if (widget.getBoxesByFiltersCommand.state case CommandFailure(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Modular.to.pushNamed("/box/form"),
        child: const Icon(Icons.add),
      ),
      appBar: CustomAppBarPrimary(
        colors: Theme.of(context).colors,
        title: 'Box Map',
        actions: [
          IconButton(
            onPressed: () {
              _showFilterDialog();
            },
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              widget.controller.fetchInitialBoxes();
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
                listenable: widget.getBoxesByFiltersCommand,
                builder: (context, child) {
                  return switch (widget.getBoxesByFiltersCommand.state) {
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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar por Zona',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Todas'),
              trailing: widget.getBoxesByFiltersCommand.currentBoxZone == null
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                widget.controller.setBoxZone(null);

                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Segura'),
              trailing:
                  widget.getBoxesByFiltersCommand.currentBoxZone ==
                      BoxZoneEnum.safe
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                widget.controller.setBoxZone(BoxZoneEnum.safe);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Moderada'),
              trailing:
                  widget.getBoxesByFiltersCommand.currentBoxZone ==
                      BoxZoneEnum.moderate
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                widget.controller.setBoxZone(BoxZoneEnum.moderate);

                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Perigosa'),
              trailing:
                  widget.getBoxesByFiltersCommand.currentBoxZone ==
                      BoxZoneEnum.danger
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                widget.controller.setBoxZone(BoxZoneEnum.danger);

                Navigator.pop(context);
              },
            ),

            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),
    );
  }
}
