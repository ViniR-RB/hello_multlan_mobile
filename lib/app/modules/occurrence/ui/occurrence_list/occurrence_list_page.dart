import 'package:flutter/material.dart';
import 'package:hello_multlan/app/modules/occurrence/ui/occurrence_list/occurrence_list_controller.dart';

class OccurrenceListPage extends StatelessWidget {
  final OccurrenceListController controller;
  const OccurrenceListPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Container(),
    );
  }
}
