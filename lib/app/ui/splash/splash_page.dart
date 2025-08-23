import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/ui/splash/command/user_logged.dart';
import 'package:hello_multlan/app/ui/splash/splash_controller.dart';

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

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    widget._controller.userIsLogged();
    widget._userLogged.addListener(_listernerUserLogged);
  }

  void _listernerUserLogged() {
    final state = widget._userLogged.state;

    if (state case CommandSuccess(value: final isLogged)) {
      final String path = switch (isLogged) {
        true => '/home',
        false => '/login',
        _ => '/login',
      };
      Modular.to.navigate(path);
    }
    if (state case CommandFailure(exception: final exception)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${exception.message}')),
      );
    }
  }

  @override
  void dispose() {
    widget._userLogged.removeListener(_listernerUserLogged);
    super.dispose();
  }

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
