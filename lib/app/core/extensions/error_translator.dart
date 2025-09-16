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
      case "imagePickerNotFound":
        return l10n.imagePickerNotFound;
      case "timeout":
        return l10n.timeout;
      case "noteMinLength":
        return l10n.noteMinLength;
      case "filledSpaceGreaterThanFreeSpace":
        return l10n.filledSpaceGreaterThanFreeSpace;
      case "fieldRequired":
        return l10n.fieldRequired;
      case "mapNotLoading":
        return l10n.mapNotLoading;
      default:
        return l10n.unknownError;
    }
  }
}
