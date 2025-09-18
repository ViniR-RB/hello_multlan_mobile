import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/extensions/loader_message.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/core/widgets/custom_scaffold_foreground.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/commands/logout_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_hub/box_hub_controller.dart';
import 'package:hello_multlan/app/modules/box/ui/box_hub/widgets/menu_option_card.dart';

class BoxHubPage extends StatefulWidget {
  final BoxHubController controller;
  final LogoutCommand logoutCommand;
  const BoxHubPage({
    super.key,
    required this.controller,
    required this.logoutCommand,
  });

  @override
  State<BoxHubPage> createState() => _BoxHubPageState();
}

class _BoxHubPageState extends State<BoxHubPage> with LoaderMessageMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.logoutCommand.addListener(_logoutLister);
    });
  }

  _logoutLister() {
    if (widget.logoutCommand.state is CommandLoading) {
      notifier.showLoader();
    }
    if (widget.logoutCommand.state is CommandSuccess) {
      notifier.hideLoader();

      Modular.to.navigate("/login");
    }
  }

  @override
  void dispose() {
    widget.logoutCommand.removeListener(_logoutLister);
    widget.controller.dipose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldForegroud(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuOptionCard(
              icon: Icons.map_outlined,
              title: "Mapa",
              subtitle: "Visualizar mapa",
              iconColor: Colors.blue,
              onTap: () => Modular.to.pushNamed("/box/map"),
            ),
            MenuOptionCard(
              icon: Icons.inventory_2_outlined,
              title: "Caixa",
              subtitle: "Adicionar nova caixa",
              iconColor: Colors.blue,
              onTap: () => Modular.to.pushNamed("/box/form"),
            ),
            MenuOptionCard(
              icon: Icons.report_problem_outlined,
              title: "Ocorrência",
              subtitle: "Gerenciar ocorrências",
              iconColor: Colors.orange,
              onTap: () => Modular.to.pushNamed("/occurrence"),
            ),
            MenuOptionCard(
              icon: Icons.report_problem_outlined,
              title: "Sair",
              subtitle: "Encerrar sessão",
              iconColor: Colors.red,
              onTap: () => widget.controller.logout(),
            ),
          ],
        ),
      ),
    );
  }
}
