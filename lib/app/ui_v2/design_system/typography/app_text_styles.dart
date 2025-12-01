import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/app_colors_v2.dart';

class AppTextStyles {
  // Heading Styles
  static TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppColorsV2.textPrimary,
    height: 1.2,
  );
  
  static TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColorsV2.textPrimary,
    height: 1.3,
  );
  
  static TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColorsV2.textPrimary,
    height: 1.4,
  );
  
  static TextStyle get heading4 => GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColorsV2.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
        height: 1.35,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
        height: 1.4,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: AppColorsV2.textPrimary,
        height: 1.4,
      );
  
  // Body Text Styles
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColorsV2.textPrimary,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColorsV2.textPrimary,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColorsV2.textSecondary,
    height: 1.4,
  );
  
  // Caption Styles
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColorsV2.textSecondary,
    height: 1.4,
  );
  
  static TextStyle get captionSmall => GoogleFonts.inter(
    fontSize: 10.sp,
    fontWeight: FontWeight.normal,
    color: AppColorsV2.textTertiary,
    height: 1.3,
  );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColorsV2.textSecondary,
        height: 1.2,
      );
  
  // Button Text Styles
  static TextStyle get buttonLarge => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColorsV2.textOnPrimary,
    height: 1.2,
  );
  
  static TextStyle get buttonMedium => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColorsV2.textOnPrimary,
    height: 1.2,
  );
  
  static TextStyle get buttonSmall => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColorsV2.textOnPrimary,
    height: 1.2,
  );
  
  // Link Styles
  static TextStyle get link => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColorsV2.primary,
    decoration: TextDecoration.underline,
    height: 1.4,
  );
  
  // White Text Styles (for overlays)
  static TextStyle get heading1White => heading1.copyWith(
    color: AppColorsV2.textOnPrimary,
  );
  
  static TextStyle get heading2White => heading2.copyWith(
    color: AppColorsV2.textOnPrimary,
  );
  
  static TextStyle get bodyLargeWhite => bodyLarge.copyWith(
    color: AppColorsV2.textOnPrimary,
  );
  
  static TextStyle get bodyMediumWhite => bodyMedium.copyWith(
    color: AppColorsV2.textOnPrimary,
  );
  
  // Subtitle & Labels
  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColorsV2.textSecondary,
        height: 1.4,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColorsV2.textSecondary,
      );

  // Secondary Text Styles
  static TextStyle get bodyLargeSecondary => bodyLarge.copyWith(
    color: AppColorsV2.textSecondary,
  );
  
  static TextStyle get bodyMediumSecondary => bodyMedium.copyWith(
    color: AppColorsV2.textSecondary,
  );

  // Button Styles
  static TextStyle get buttonPrimary => buttonLarge;

  static TextStyle get buttonSecondary => buttonLarge.copyWith(
        color: AppColorsV2.primary,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.primary,
      );

  static TextStyle get chipLabel => GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
      );

  static TextStyle get badge => GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textOnPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get captionSecondary =>
      caption.copyWith(color: AppColorsV2.textSecondary);

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColorsV2.textSecondary,
      );
}




