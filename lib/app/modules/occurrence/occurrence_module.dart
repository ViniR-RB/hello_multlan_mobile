import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/core_module.dart';
import 'package:hello_multlan/app/core/data/rest_client/rest_client.dart';
import 'package:hello_multlan/app/modules/occurrence/gateway/occurrence_gateway.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/occurrence_repository.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/occurrence_repository_impl.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/command/cancel_occurrence_command.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/command/get_all_occurrence_command.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/command/resolve_occurrence_command.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/occurrence_list_controller.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/occurrence_list_page.dart';

class OccurrenceModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.addLazySingleton<OccurrenceRepository>(OccurrenceRepositoryImpl.new);
    i.addLazySingleton(() => OccurrenceGateway(Modular.get<RestClient>()));
    i.add(GetAllOccurrenceCommand.new);
    i.add(CancelOccurrenceCommand.new);
    i.add(ResolveOccurrenceCommand.new);
  }

  @override
  void exportedBinds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child(
      "/",
      child: (_) {
        final GetAllOccurrenceCommand getAllOccurrenceCommand =
            Modular.get<GetAllOccurrenceCommand>();
        final CancelOccurrenceCommand cancelOccurrenceCommand =
            Modular.get<CancelOccurrenceCommand>();
        final ResolveOccurrenceCommand resolveOccurrenceCommand =
            Modular.get<ResolveOccurrenceCommand>();
        final OccurrenceListController controller = OccurrenceListController(
          getAllOccurrenceCommand: getAllOccurrenceCommand,
          cancelOccurrenceCommand: cancelOccurrenceCommand,
          resolveOccurrenceCommand: resolveOccurrenceCommand,
        );

        return OccurrenceListPage(
          getAllOccurrenceCommand: getAllOccurrenceCommand,
          cancelOccurrenceCommand: cancelOccurrenceCommand,
          resolveOccurrenceCommand: resolveOccurrenceCommand,
          controller: controller,
        );
      },
    );
  }
}
