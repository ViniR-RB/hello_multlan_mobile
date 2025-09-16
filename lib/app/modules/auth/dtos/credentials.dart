import 'package:flutter/material.dart';
import 'package:lucid_validation/lucid_validation.dart';

class Credentials extends ChangeNotifier {
  String email;
  String password;

  setPassword(String value) {
    password = value;
    notifyListeners();
  }

  setEmail(String value) {
    email = value;
    notifyListeners();
  }

  Credentials({
    this.email = "",
    this.password = "",
  });
}

class CredentialsValidator extends LucidValidator<Credentials> {
  CredentialsValidator() {
    ruleFor(
      (credentials) => credentials.email,
      key: 'email',
    ).notEmpty().validEmail();

    ruleFor(
      (credentials) => credentials.email,
      key: 'email',
    ).notEmpty().minLength(6);
  }
}
