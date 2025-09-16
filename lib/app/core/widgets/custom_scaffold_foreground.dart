import 'package:flutter/material.dart';
import 'package:hello_multlan/gen/assets.gen.dart';

class CustomScaffoldForegroud extends StatelessWidget {
  final PreferredSizeWidget? customAppBar;
  final Widget child;
  const CustomScaffoldForegroud({
    super.key,
    this.customAppBar,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar,
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            opacity: 0.1,
            image: Assets.images.background1.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    );
  }
}
