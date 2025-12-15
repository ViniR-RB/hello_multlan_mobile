import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/theme/app_colors.dart';
import 'package:hello_multlan/gen/assets.gen.dart';

class CustomAppBarPrimary extends PreferredSize {
  final String title;
  final List<Widget>? actions;

  CustomAppBarPrimary({
    super.key,
    required this.title,
    this.actions,
    required AppColors colors,
  }) : super(
         preferredSize: const Size.fromHeight(96),
         child: AppBar(
           actions: actions,
           title: Text(title),
           leading: Modular.to.canPop()
               ? IconButton(
                   icon: const Icon(Icons.chevron_left, size: 40),
                   onPressed: () => Modular.to.pop(),
                 )
               : const SizedBox.shrink(),
           iconTheme: const IconThemeData(color: Colors.white),
           titleTextStyle: const TextStyle(
             color: Colors.white,
             fontSize: 26,
             fontWeight: FontWeight.w800,
           ),
           backgroundColor: colors.primaryColor,
           centerTitle: true,
           elevation: 12,
           flexibleSpace: const CustomAppBarContent(),
           shadowColor: const Color(0xFF999999),
         ),
       );
}

class CustomAppBarContent extends StatelessWidget {
  const CustomAppBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          opacity: 0.45,
          image: Assets.images.background1.provider(),
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
