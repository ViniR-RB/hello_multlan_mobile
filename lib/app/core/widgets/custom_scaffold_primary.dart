import 'package:flutter/material.dart';
import 'package:hello_multlan/gen/assets.gen.dart';

class CustomScaffoldPrimary extends StatelessWidget {
  final PreferredSizeWidget? customAppBar;
  final Widget child;
  const CustomScaffoldPrimary({
    super.key,
    this.customAppBar,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            opacity: 0.45,
            image: Assets.images.background1.provider(),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    );
  }
}
