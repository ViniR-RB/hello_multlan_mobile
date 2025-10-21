import 'package:flutter/foundation.dart';
import 'package:lucid_validation/lucid_validation.dart';

class ResetPasswordDto extends ChangeNotifier {
  String oldPassword;
  String newPassword;
  String confirmPassword;

  ResetPasswordDto({
    this.oldPassword = "",
    this.newPassword = "",
    this.confirmPassword = "",
  });

  set setOldPassword(String value) {
    oldPassword = value;
    notifyListeners();
  }

  set setNewPassword(String value) {
    newPassword = value;
    notifyListeners();
  }

  set setConfirmPassword(String value) {
    confirmPassword = value;
    notifyListeners();
  }

  void clear() {
    oldPassword = "";
    newPassword = "";
    confirmPassword = "";
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}

class ResetPasswordDtoValidator extends LucidValidator<ResetPasswordDto> {
  ResetPasswordDtoValidator() {
    ruleFor(
      (dto) => dto.oldPassword,
      key: "oldPassword",
    ).notEmpty().minLength(6);

    ruleFor(
      (dto) => dto.newPassword,
      key: "newPassword",
    ).notEmpty().minLength(6);

    ruleFor(
      (dto) => dto.confirmPassword,
      key: "confirmPassword",
    ).notEmpty().mustWith(
      (confirmPassword, dto) => confirmPassword == dto.newPassword,
      "passwordsDoNotMatch",
      "passwordsDoNotMatch",
    );
  }
}
