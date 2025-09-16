import 'package:flutter/material.dart';

class UserLocationWidget extends StatelessWidget {
  const UserLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueAccent,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }
}
