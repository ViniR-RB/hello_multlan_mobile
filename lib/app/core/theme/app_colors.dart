import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primaryColor;
  final Color cardColor;

  const AppColors({
    required this.primaryColor,
    required this.cardColor,
  });

  @override
  AppColors copyWith({
    Color? primaryColor,
    Color? cardColor,
  }) {
    return AppColors(
      primaryColor: primaryColor ?? this.primaryColor,
      cardColor: cardColor ?? this.cardColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
    );
  }

  // Tema claro
  static const light = AppColors(
    primaryColor: Color(0xFF004AAD),
    cardColor: Color(0xFFFAFAFA),
  );
}
