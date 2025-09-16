import 'package:flutter/material.dart';

class BoxFieldDetail extends StatelessWidget {
  final String label;
  final String value;
  const BoxFieldDetail({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          value,
          overflow: TextOverflow.clip,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w200),
        ),
      ],
    );
  }
}
