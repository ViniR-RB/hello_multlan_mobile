import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/extensions/error_translator.dart';
import 'package:hello_multlan/app/core/extensions/loader_message.dart';
import 'package:hello_multlan/app/core/extensions/success_translator.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/auth/dtos/credentials.dart';
import 'package:hello_multlan/app/ui/login/command/login_command.dart';
import 'package:hello_multlan/app/ui/login/login_controller.dart';

class LoginPage extends StatefulWidget {
  final LoginController controller;
  final LoginCommand loginCommand;
  const LoginPage({
    super.key,
    required this.controller,
    required this.loginCommand,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with ErrorTranslator, SuccessTranslator, LoaderMessageMixin {
  @override
  void initState() {
    super.initState();
    widget.loginCommand.addListener(_listernetLogin);
  }

  _listernetLogin() {
    final state = widget.loginCommand.state;

    if (state is CommandLoading) {
      notifier.showLoader();
    }

    if (state case CommandFailure(exception: final exception)) {
      notifier.hideLoader();

      notifier.showMessage(
        translateError(context, exception.code),
        SnackType.error,
      );
    }
    if (state is CommandSuccess) {
      notifier.hideLoader();

      notifier.showMessage(
        translateSuccess(context, "successInLogin"),
        SnackType.success,
      );
      Modular.to.navigate("/box/");
    }
  }

  final validator = CredentialsValidator();

  final Credentials credentials = Credentials();

  bool _isValid() {
    final valid = validator.validate(credentials);
    return valid.isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            onChanged: credentials.setEmail,
            validator: validator.byField(credentials, "email"),

            decoration: const InputDecoration(
              labelText: 'E-mail',
            ),
          ),
          TextFormField(
            onChanged: credentials.setPassword,
            validator: validator.byField(credentials, "password"),
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),

          ListenableBuilder(
            listenable: credentials,
            builder: (context, child) {
              return ElevatedButton(
                onPressed: _isValid()
                    ? () {
                        widget.controller.login(credentials);
                      }
                    : null,
                child: Text("Login"),
              );
            },
          ),
        ],
      ),
    );
  }
}
