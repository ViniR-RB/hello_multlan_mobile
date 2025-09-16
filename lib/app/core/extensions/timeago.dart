import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

extension TimeAgoStringExtension on String {
  String toTimeAgo({Locale locale = const Locale('pt', 'BR')}) {
    try {
      final date = DateTime.parse(this);

      // Retornar o tempo relativo
      final String timeFormated = timeago.format(
        date,
        locale: locale.languageCode,
      );
      return timeFormated;
    } catch (e) {
      return "Data inválida";
    }
  }
}
