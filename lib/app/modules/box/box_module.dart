import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/core_module.dart';
import 'package:hello_multlan/app/core/data/rest_client/rest_client.dart';
import 'package:hello_multlan/app/modules/box/gateway/box_gateway.dart';
import 'package:hello_multlan/app/modules/box/repositories/box_repository.dart';
import 'package:hello_multlan/app/modules/box/repositories/box_repository_impl.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/box_form_controller.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/box_form_page.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/commands/create_box_data_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/commands/get_image_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/commands/get_user_location_send_form_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_hub/box_hub_page.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/box_map_controller.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/box_map_page.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/get_all_boxes_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map/command/watch_user_position_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_map_detail/commands/get_box_by_id_command.dart';
import 'package:hello_multlan/app/modules/geo_locator/geo_locator_module.dart';

class BoxModule extends Module {
  @override
  List<Module> get imports => [
    CoreModule(),
    GeoLocatorModule(),
  ];

  @override
  void binds(Injector i) {
    i.addLazySingleton<BoxRepository>(BoxRepositoryImpl.new);
    i.addLazySingleton(() => BoxGateway(Modular.get<RestClient>()));

    i.add(GetAllBoxesCommand.new);
    i.add(GetImageCommand.new);
    i.add(WatchUserPositionCommand.new);
    i.add(GetUserLocationSendFormCommand.new);
    i.add(CreateBoxDataCommand.new);
    i.add(GetBoxByIdCommand.new);
  }

  @override
  void exportedBinds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child("/", child: (_) => BoxHubPage());
    r.child(
      "/form",
      child: (_) {
        final getImageCommand = Modular.get<GetImageCommand>();

        final getUserLocationSendFormCommand =
            Modular.get<GetUserLocationSendFormCommand>();

        final createBoxDataCommand = Modular.get<CreateBoxDataCommand>();

        final controller = BoxFormController(
          getImageCommand: getImageCommand,
          createBoxCommand: createBoxDataCommand,
          getUserLocationSendFormCommand: getUserLocationSendFormCommand,
        );
        return BoxFormPage(
          controller: controller,
          getImageCommand: getImageCommand,
          getUserLocationSendFormCommand: getUserLocationSendFormCommand,
          createBoxDataCommand: createBoxDataCommand,
        );
      },
    );
    r.child(
      "/map",
      child: (_) {
        final GetAllBoxesCommand getAllBoxesCommand =
            Modular.get<GetAllBoxesCommand>();

        final WatchUserPositionCommand watchUserPositionCommand =
            Modular.get<WatchUserPositionCommand>();

        final BoxMapController controller = BoxMapController(
          getAllBoxesCommand: getAllBoxesCommand,
          watchUserPositionCommand: watchUserPositionCommand,
        );

        return BoxMapPage(
          controller: controller,
          getAllBoxesCommand: getAllBoxesCommand,
          watchUserPositionCommand: watchUserPositionCommand,
        );
      },
    );
  }
}
