import 'package:flutter/material.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/auth/repositories/auth_repository.dart';

class UserLogged extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserLogged({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  CommandState<bool?, AppException> _state = CommandInitial(
    null,
  );

  CommandState<bool?, AppException> get state => _state;

  Future<void> execute() async {
    _state = CommandLoading();
    notifyListeners();

    final isLogged = await _authRepository.isLogged().flatMap((logged) async {
      final whoIam = await _authRepository.whoIAm();
      return whoIam;
    });

    isLogged.when(
      onSuccess: (isLogged) async {
        _state = CommandSuccess(true);
      },
      onFailure: (AppException exception) {
        _state = CommandFailure(exception);
      },
    );
    notifyListeners();
  }
}
