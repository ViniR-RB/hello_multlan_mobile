import 'package:flutter/material.dart';
import 'package:hello_multlan/app/core/theme/app_colors.dart';

ThemeData get appTheme {
  const colors = AppColors.light;

  return ThemeData(
    extensions: [colors],
    colorScheme: ColorScheme.light(
      primary: colors.primaryColor,
      onPrimary: colors.cardColor,
    ),
  );
}
