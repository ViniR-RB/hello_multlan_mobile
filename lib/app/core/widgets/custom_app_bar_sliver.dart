import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/extensions/theme_extension.dart';
import 'package:hello_multlan/app/core/theme/app_colors.dart';
import 'package:hello_multlan/app/gen/assets.gen.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const CustomSliverAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = Theme.of(context).colors;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      elevation: 12,
      expandedHeight: 160,
      collapsedHeight: statusBarHeight + 64,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      backgroundColor: colors.primaryColor,
      automaticallyImplyLeading: false,
      leading: Modular.to.canPop()
          ? IconButton(
              icon: const Icon(
                Icons.chevron_left,
                size: 32,
                color: Colors.white,
              ),
              onPressed: () => Modular.to.pop(),
            )
          : null,
      centerTitle: true,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 20,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        background: Container(
          decoration: BoxDecoration(
            color: colors.primaryColor,
            image: DecorationImage(
              opacity: 0.45,
              image: Assets.images.background1.provider(),
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.primaryColor.withValues(alpha: 0.8),
                  colors.primaryColor.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
