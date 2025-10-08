import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/extensions/error_translator.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/core/widgets/custom_scaffold_primary.dart';
import 'package:hello_multlan/app/ui/splash/command/user_logged.dart';
import 'package:hello_multlan/app/ui/splash/splash_controller.dart';
import 'package:hello_multlan/gen/assets.gen.dart';

class SplashPage extends StatefulWidget {
  final SplashController _controller;
  final UserLogged _userLogged;

  const SplashPage({
    super.key,
    required SplashController controller,
    required UserLogged userLogged,
  }) : _userLogged = userLogged,
       _controller = controller;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with ErrorTranslator, TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    widget._userLogged.addListener(_listernerUserLogged);
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _opacityAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // Inicia a animação e executa userIsLogged durante a animação
    _animationController.forward().then((_) {
      // Após a animação completar, executa a verificação
      widget._controller.userIsLogged();
    });
  }

  void _listernerUserLogged() {
    final state = widget._userLogged.state;

    if (state case CommandSuccess(value: final isLogged)) {
      final String path = switch (isLogged) {
        true => '/box',
        false => '/login',
        _ => '/login',
      };
      Modular.to.navigate(path);
    }
    if (state case CommandFailure(exception: final exception)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translateError(context, exception.code))),
      );
      Modular.to.navigate("/login");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget._userLogged.removeListener(_listernerUserLogged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldPrimary(
      child: Center(
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Assets.images.logoCompleta.image(width: 200, height: 200),
            );
          },
        ),
      ),
    );
  }
}
