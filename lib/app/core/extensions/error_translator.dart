import 'package:flutter/material.dart';
import 'package:hello_multlan/l10n/app_localizations.dart';

mixin ErrorTranslator<T extends StatefulWidget> on State<T> {
  String translateError(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case "networkError":
        return l10n.networkError;
      case "invalidCredentials":
        return l10n.invalidCredentials;
      case "localStorageNotFoundKey":
        return l10n.localStorageNotFoundKey;
      case "unauthorized":
        return l10n.unauthorized;
      case "locationServiceDisabled":
        return l10n.locationServiceDisabled;
      default:
        return l10n.unknownError;
    }
  }
}
