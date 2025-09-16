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
    inputDecorationTheme: InputDecorationTheme(
      // Bordas
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),

      // Preenchimento e padding
      filled: true,
      fillColor: colors.cardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      // Cores dos textos
      labelStyle: TextStyle(
        color: Colors.grey[600],
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: colors.primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      helperStyle: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),

      // Comportamento
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      alignLabelWithHint: true,

      // Ícones
      prefixIconColor: Colors.grey[600],
      suffixIconColor: Colors.grey[600],

      // Densidade
      isDense: false,
    ),
  );
}
