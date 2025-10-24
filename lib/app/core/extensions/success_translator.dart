import 'package:flutter/material.dart';
import 'package:hello_multlan/l10n/app_localizations.dart';

mixin SuccessTranslator<T extends StatefulWidget> on State<T> {
  String translateSuccess(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case "successInLogin":
        return l10n.successInLogin;
      case "successInCreateBox":
        return l10n.successInCreateBox;
      case "passwordResetSuccess":
        return l10n.passwordResetSuccess;
      case "successInUpdateBox":
        return l10n.successInUpdateBox;
      default:
        return l10n.unknownError;
    }
  }
}
