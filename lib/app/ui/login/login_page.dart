import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/core/extensions/error_translator.dart';
import 'package:hello_multlan/app/core/extensions/loader_message.dart';
import 'package:hello_multlan/app/core/extensions/success_translator.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/core/widgets/custom_scaffold_primary.dart';
import 'package:hello_multlan/app/modules/auth/dtos/credentials.dart';
import 'package:hello_multlan/app/ui/login/command/login_command.dart';
import 'package:hello_multlan/app/ui/login/login_controller.dart';
import 'package:hello_multlan/gen/assets.gen.dart';

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
  void dispose() {
    widget.loginCommand.removeListener(_listernetLogin);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isExtraSmallScreen = screenHeight < 600;

    return CustomScaffoldPrimary(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    // Parte superior com logo - Adaptável
                    SizedBox(
                      height: isExtraSmallScreen
                          ? constraints.maxHeight * 0.25
                          : isSmallScreen
                          ? constraints.maxHeight * 0.3
                          : constraints.maxHeight * 0.35,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Assets.images.logoCompleta.image(
                            width: isExtraSmallScreen
                                ? screenWidth * 0.6
                                : isSmallScreen
                                ? screenWidth * 0.7
                                : screenWidth * 0.8,
                            height: isExtraSmallScreen
                                ? 80
                                : isSmallScreen
                                ? 100
                                : 120,
                          ),
                        ],
                      ),
                    ),

                    // Parte inferior com formulário - Adaptável
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 24.0 : 32.0,
                          vertical: isExtraSmallScreen ? 16.0 : 24.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Faça Login',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Campo E-mail
                            Text(
                              'E-mail',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              onChanged: credentials.setEmail,
                              validator: validator.byField(
                                credentials,
                                "email",
                              ),
                              decoration: InputDecoration(
                                hintText: 'Digite seu e-mail',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Campo Senha
                            Text(
                              'Senha',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              onChanged: credentials.setPassword,
                              validator: validator.byField(
                                credentials,
                                "password",
                              ),
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Digite sua senha',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            ListenableBuilder(
                              listenable: credentials,
                              builder: (context, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isValid()
                                        ? () {
                                            widget.controller.login(
                                              credentials,
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF1565C0),
                                      disabledBackgroundColor: Colors.grey[300],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "Entrar",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Espaço extra para evitar problemas de teclado
                            SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
