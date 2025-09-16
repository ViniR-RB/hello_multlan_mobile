import 'package:flutter/material.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/auth/dtos/credentials.dart';
import 'package:hello_multlan/app/modules/auth/repositories/auth_repository.dart';

class LoginCommand extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginCommand({required AuthRepository authRepository})
    : _authRepository = authRepository;

  CommandState<bool?, AppException> _state = CommandInitial(null);
  CommandState<bool?, AppException> get state => _state;

  _setState(CommandState<bool?, AppException> state) {
    _state = state;
    notifyListeners();
  }

  Future<void> execute(Credentials credentials) async {
    _setState(CommandLoading());

    final loginResult = await _authRepository.login(credentials);

    loginResult.when(
      onSuccess: (_) {
        _setState(CommandSuccess(true));
      },
      onFailure: (error) {
        _setState(CommandFailure(error));
      },
    );
  }
}
