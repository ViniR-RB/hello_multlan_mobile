import 'package:flutter/material.dart';
import 'package:hello_multlan/app/core/extensions/error_translator.dart';
import 'package:hello_multlan/app/core/extensions/loader_message.dart';
import 'package:hello_multlan/app/core/extensions/success_translator.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/core/widgets/custom_app_bar_sliver.dart';
import 'package:hello_multlan/app/core/widgets/custom_scaffold_foreground.dart';
import 'package:hello_multlan/app/modules/auth/dtos/reset_password_dto.dart';
import 'package:hello_multlan/app/modules/auth/models/user_model.dart';
import 'package:hello_multlan/app/modules/auth/ui/user_profile/commands/reset_password_command.dart';
import 'package:hello_multlan/app/modules/auth/ui/user_profile/commands/who_i_am_command.dart';
import 'package:hello_multlan/app/modules/auth/ui/user_profile/user_profile_controller.dart';

class UserProfilePage extends StatefulWidget {
  final UserProfileController controller;
  final ResetPasswordCommand resetPasswordCommand;
  final WhoIAmCommand whoIAmCommand;

  const UserProfilePage({
    super.key,
    required this.controller,
    required this.resetPasswordCommand,
    required this.whoIAmCommand,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with LoaderMessageMixin, ErrorTranslator, SuccessTranslator {
  final _formKey = GlobalKey<FormState>();
  final _resetPasswordDto = ResetPasswordDto();
  final _validator = ResetPasswordDtoValidator();

  bool _isChangingPassword = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    widget.resetPasswordCommand.addListener(_onResetPasswordStateChange);
    widget.controller.refreshUserData();
  }

  void _onResetPasswordStateChange() {
    final state = widget.resetPasswordCommand.state;

    switch (state) {
      case CommandLoading():
        notifier.showLoader();
        break;
      case CommandSuccess():
        notifier.hideLoader();
        notifier.showMessage(
          translateSuccess(context, "passwordResetSuccess"),
          SnackType.success,
        );
        _resetPasswordDto.clear();
        _formKey.currentState?.reset();
        setState(() {
          _isChangingPassword = false;
        });
        // Atualizar dados do usu??rio ap??s reset
        widget.controller.refreshUserData();
        break;
      case CommandFailure(exception: final error):
        notifier.hideLoader();
        notifier.showMessage(
          translateError(context, error.code),
          SnackType.error,
        );
        break;
      default:
        break;
    }
  }

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.controller.resetPassword(_resetPasswordDto);
    }
  }

  @override
  void dispose() {
    widget.resetPasswordCommand.removeListener(_onResetPasswordStateChange);
    _resetPasswordDto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldForegroud(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: widget.whoIAmCommand,
          builder: (context, child) {
            final whoIAmState = widget.whoIAmCommand.state;

            // Mostrar loading enquanto carrega os dados iniciais
            if (whoIAmState is CommandLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (whoIAmState case CommandSuccess(:final value)) {
              if (value == null) {
                return SizedBox.shrink();
              }
              final currentUser = value;
              return CustomScrollView(
                slivers: [
                  const CustomSliverAppBar(
                    title: "Perfil",
                    actions: [],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar e nome
                          Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    currentUser.name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  currentUser.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentUser.email,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Informações do Perfil",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    "ID",
                                    currentUser.id.toString(),
                                    Icons.badge,
                                  ),
                                  const Divider(),
                                  _buildInfoRow(
                                    "Função",
                                    switch (currentUser.role) {
                                      Role.internal => "Interno",
                                      Role.admin => "Admin",
                                    },
                                    Icons.work,
                                  ),
                                  const Divider(),
                                  _buildInfoRow(
                                    "Status",
                                    currentUser.isActive == true
                                        ? "Ativo"
                                        : "Inativo",
                                    Icons.check_circle,
                                  ),
                                  const Divider(),
                                  _buildInfoRow(
                                    "Criado em",
                                    _formatDate(currentUser.createdAt),
                                    Icons.calendar_today,
                                  ),
                                  const Divider(),
                                  _buildInfoRow(
                                    "Atualizado em",
                                    _formatDate(currentUser.updatedAt),
                                    Icons.update,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Se????o de altera????o de senha
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Segurança",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _isChangingPassword =
                                                !_isChangingPassword;
                                            if (!_isChangingPassword) {
                                              _resetPasswordDto.clear();
                                              _formKey.currentState?.reset();
                                            }
                                          });
                                        },
                                        icon: Icon(
                                          _isChangingPassword
                                              ? Icons.close
                                              : Icons.edit,
                                        ),
                                        label: Text(
                                          _isChangingPassword
                                              ? "Cancelar"
                                              : "Alterar Senha",
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_isChangingPassword) ...[
                                    const SizedBox(height: 16),
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          // Senha antiga
                                          TextFormField(
                                            obscureText: _obscureOldPassword,
                                            decoration: InputDecoration(
                                              labelText: "Senha Atual",
                                              prefixIcon: const Icon(
                                                Icons.lock,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureOldPassword
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureOldPassword =
                                                        !_obscureOldPassword;
                                                  });
                                                },
                                              ),
                                            ),
                                            validator: _validator.byField(
                                              _resetPasswordDto,
                                              "oldPassword",
                                            ),
                                            onChanged: (value) =>
                                                _resetPasswordDto
                                                        .setOldPassword =
                                                    value,
                                          ),
                                          const SizedBox(height: 16),
                                          // Nova senha
                                          TextFormField(
                                            obscureText: _obscureNewPassword,
                                            decoration: InputDecoration(
                                              labelText: "Nova Senha",
                                              prefixIcon: const Icon(
                                                Icons.lock_outline,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureNewPassword
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureNewPassword =
                                                        !_obscureNewPassword;
                                                  });
                                                },
                                              ),
                                            ),
                                            validator: _validator.byField(
                                              _resetPasswordDto,
                                              "newPassword",
                                            ),
                                            onChanged: (value) =>
                                                _resetPasswordDto
                                                        .setNewPassword =
                                                    value,
                                          ),
                                          const SizedBox(height: 16),
                                          // Confirmar senha
                                          TextFormField(
                                            obscureText:
                                                _obscureConfirmPassword,
                                            decoration: InputDecoration(
                                              labelText: "Confirmar Nova Senha",
                                              prefixIcon: const Icon(
                                                Icons.lock_outline,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureConfirmPassword
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureConfirmPassword =
                                                        !_obscureConfirmPassword;
                                                  });
                                                },
                                              ),
                                            ),
                                            validator: _validator.byField(
                                              _resetPasswordDto,
                                              "confirmPassword",
                                            ),
                                            onChanged: (value) =>
                                                _resetPasswordDto
                                                        .setConfirmPassword =
                                                    value,
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: _handleResetPassword,
                                              child: const Text(
                                                "Salvar Nova Senha",
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
