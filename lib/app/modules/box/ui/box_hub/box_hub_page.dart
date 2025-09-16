import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/widgets/custom_scaffold_foreground.dart';
import 'package:hello_multlan/app/modules/box/ui/box_hub/widgets/menu_option_card.dart';

class BoxHubPage extends StatelessWidget {
  const BoxHubPage({super.key});

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
          ],
        ),
      ),
    );
  }
}
