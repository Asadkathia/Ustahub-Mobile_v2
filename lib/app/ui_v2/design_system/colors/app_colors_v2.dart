import 'package:flutter/material.dart';

class AppColorsV2 {
  // Primary Teal Color Palette
  static const primary = Color(0xFF00BEC6); // Brand teal
  static const primaryDark = Color(0xFF008A90); // Deeper teal for gradients
  static const primaryLight = Color(0xFF5ADFE5); // Lighter teal accents
  static const primaryContainer = Color(0xFFE0F8F9); // Light teal container

  // Neutral / Background palette
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF7F8F9);
  static const surfaceVariant = Color(0xFFF1F2F4);
  static const cardBackground = Color(0xFFFFFFFF);
  static const inputBackground = Color(0xFFFBFBFB);

  // Text Colors
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF5A5F66);
  static const textTertiary = Color(0xFFA0A6AD);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textWhite = Color(0xFFFFFFFF);

  // Semantic Colors
  static const success = Color(0xFF4CAF50);
  static const successContainer = Color(0xFFE6F6EA);
  static const warning = Color(0xFFFFB020);
  static const warningContainer = Color(0xFFFFF3E0);
  static const info = Color(0xFF2196F3);
  static const infoContainer = Color(0xFFE3F2FD);
  static const error = Color(0xFFE53935);
  static const errorContainer = Color(0xFFFFEBEE);

  // Accent Colors
  static const accentPurple = Color(0xFF8F67FF);
  static const accentBlue = Color(0xFF3F8CFF);
  static const accentPink = Color(0xFFFF5C8D);

  // Border / Divider
  static const borderLight = Color(0xFFE3E6EA);
  static const borderMedium = Color(0xFFC4C9D0);
  static const borderFocus = primary;
  static const divider = Color(0xFFEFF1F4);
  static const inputBorderLight = Color(0xFFE6E6E6);
  static const inputBorder = Color(0xFFC4C4C4);

  // Overlay / states
  static const overlay = Color(0xAA000000);
  static const disabled = Color(0xFFE0E0E0);
  static const disabledText = Color(0xFF9E9E9E);
  static const chipBackground = Color(0xFFEFF6F7);

  // Gradient Colors
  static const gradientStart = Color(0xFF00BEC6);
  static const gradientEnd = Color(0xFF006E73);

  static LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientEnd],
      );

  static LinearGradient get imageOverlayGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientStart.withOpacity(0.7),
          gradientEnd.withOpacity(0.9),
        ],
      );

  static LinearGradient get overlayGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientStart.withOpacity(0.6),
          gradientEnd.withOpacity(0.85),
        ],
      );

  // Shadow Colors
  static const shadowLight = Color(0x14000000);
  static const shadowMedium = Color(0x1F000000);
  static const shadowDark = Color(0x33000000);
}




