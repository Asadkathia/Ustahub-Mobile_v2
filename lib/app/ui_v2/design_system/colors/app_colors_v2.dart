import 'package:flutter/material.dart';

class AppColorsV2 {
  // Primary Teal Color Palette
  static const primary = Color(0xFF00BEC6); // Updated brand teal
  static const primaryDark = Color(0xFF008A90); // Deeper teal for gradients
  static const primaryLight = Color(0xFF5ADFE5); // Lighter teal for accents
  static const primaryContainer = Color(0xFFE0F8F9); // Light teal container
  
  // Background Colors
  static const background = Color(0xFFFFFFFF); // White background
  static const surface = Color(0xFFF5F5F5); // Light grey surface
  static const surfaceVariant = Color(0xFFFAFAFA); // Very light grey
  
  // Text Colors
  static const textPrimary = Color(0xFF1A1A1A); // Dark grey/black for primary text
  static const textSecondary = Color(0xFF808080); // Medium grey for secondary text
  static const textTertiary = Color(0xFFB0B0B0); // Light grey for tertiary text
  static const textOnPrimary = Color(0xFFFFFFFF); // White text on teal background
  static const textWhite = Color(0xFFFFFFFF);
  
  // Semantic Colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);
  
  // Border Colors
  static const borderLight = Color(0xFFE0E0E0);
  static const borderMedium = Color(0xFFBDBDBD);
  static const borderFocus = primary; // Teal border when focused
  static const inputBorderLight = Color(0xFFE6E6E6);
  static const inputBorder = Color(0xFFC4C4C4);
  
  // Gradient Colors
  static const gradientStart = Color(0xFF00BEC6); // Teal
  static const gradientEnd = Color(0xFF006E73); // Darker teal/blue

  // Surfaces
  static const cardBackground = Color(0xFFFFFFFF);
  static const inputBackground = Color(0xFFF9F9F9);
  
  // Gradient for overlays
  static LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );
  
  // Overlay gradient for images (teal to darker teal/blue)
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
  
  // Disabled Colors
  static const disabled = Color(0xFFE0E0E0);
  static const disabledText = Color(0xFF9E9E9E);
  
  // Shadow Colors
  static const shadowLight = Color(0x1A000000);
  static const shadowMedium = Color(0x33000000);
  static const shadowDark = Color(0x4D000000);
}




