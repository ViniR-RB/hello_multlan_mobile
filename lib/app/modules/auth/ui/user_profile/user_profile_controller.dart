import 'package:flutter/material.dart';
import 'package:hello_multlan/app/modules/auth/dtos/reset_password_dto.dart';
import 'package:hello_multlan/app/modules/auth/ui/user_profile/commands/reset_password_command.dart';
import 'package:hello_multlan/app/modules/auth/ui/user_profile/commands/who_i_am_command.dart';

class UserProfileController extends ChangeNotifier {
  final ResetPasswordCommand _resetPasswordCommand;
  final WhoIAmCommand _whoIAmCommand;

  UserProfileController({
    required ResetPasswordCommand resetPasswordCommand,
    required WhoIAmCommand whoIAmCommand,
  })  : _resetPasswordCommand = resetPasswordCommand,
        _whoIAmCommand = whoIAmCommand;

  Future<void> resetPassword(ResetPasswordDto dto) async {
    await _resetPasswordCommand.execute(dto);
  }

  Future<void> refreshUserData() async {
    await _whoIAmCommand.execute();
  }

  void dispose() {
    super.dispose();
  }
}
