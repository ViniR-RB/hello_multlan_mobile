import 'package:flutter/material.dart';
import 'package:hello_multlan/app/core/theme/app_colors.dart';

extension ThemeDataColorsExtension on ThemeData {
  AppColors get colors => extension<AppColors>()!;
}
