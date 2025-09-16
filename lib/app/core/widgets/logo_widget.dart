import 'package:flutter/material.dart';
import 'package:hello_multlan/gen/assets.gen.dart';

class LogoWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit? fit;
  const LogoWidget({super.key, this.width, this.height, this.fit});

  @override
  Widget build(BuildContext context) {
    return Assets.images.logo.image(
      width: width,
      height: height,
      fit: fit,
    );
  }
}
