import 'package:flutter/material.dart';
import 'package:hello_multlan/l10n/app_localizations.dart';

mixin SuccessTranslator<T extends StatefulWidget> on State<T> {
  String translateError(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case "successInLogin":
        return l10n.successInLogin;
      default:
        return l10n.unknownError;
    }
  }
}
