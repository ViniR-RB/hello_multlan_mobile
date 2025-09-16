import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/widgets/custom_scaffold_primary.dart';

class BoxHubPage extends StatelessWidget {
  const BoxHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldPrimary(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child: ListTile(
              title: Text("Mapa"),
              onTap: () => Modular.to.pushNamed("/box/map"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Form"),
              onTap: () => Modular.to.pushNamed("/box/form"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Occurrence"),
              onTap: () => Modular.to.pushNamed("/occurrence"),
            ),
          ),
        ],
      ),
    );
  }
}
