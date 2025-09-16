import 'package:flutter/material.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';

abstract class BaseCommand<S, F> extends ChangeNotifier {
  CommandState<S, F> _state;
  bool _isDisposed = false;

  BaseCommand(this._state);

  CommandState<S, F> get state => _state;

  @protected
  void setState(CommandState<S, F> newState) {
    if (_isDisposed == true) return;
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void reset();
}
