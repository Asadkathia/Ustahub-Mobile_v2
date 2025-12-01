import 'package:flutter/material.dart';
import '../colors/app_colors_v2.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: AppColorsV2.shadowLight,
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: AppColorsV2.shadowMedium,
          blurRadius: 18,
          offset: const Offset(0, 10),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: AppColorsV2.shadowDark,
          blurRadius: 24,
          offset: const Offset(0, 16),
          spreadRadius: -6,
        ),
      ];
}

