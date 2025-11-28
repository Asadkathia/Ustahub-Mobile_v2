import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/app_colors_v2.dart';
import '../spacing/app_spacing.dart';

class AppThemeV2 {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColorsV2.primary,
      primaryContainer: AppColorsV2.primaryContainer,
      secondary: AppColorsV2.primaryLight,
      surface: AppColorsV2.surface,
      background: AppColorsV2.background,
      error: AppColorsV2.error,
      onPrimary: AppColorsV2.textOnPrimary,
      onSecondary: AppColorsV2.textOnPrimary,
      onSurface: AppColorsV2.textPrimary,
      onBackground: AppColorsV2.textPrimary,
      onError: AppColorsV2.textOnPrimary,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColorsV2.background,
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsV2.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: AppColorsV2.textPrimary,
        size: AppSpacing.iconMedium,
      ),
      titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColorsV2.textPrimary,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: AppColorsV2.textPrimary,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: AppColorsV2.textPrimary,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColorsV2.textSecondary,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsV2.background,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.inputPaddingHorizontal,
        vertical: AppSpacing.inputPaddingVertical,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        borderSide: BorderSide(
          color: AppColorsV2.borderLight,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        borderSide: BorderSide(
          color: AppColorsV2.borderLight,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        borderSide: BorderSide(
          color: AppColorsV2.borderFocus,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        borderSide: BorderSide(
          color: AppColorsV2.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        borderSide: BorderSide(
          color: AppColorsV2.error,
          width: 2,
        ),
      ),
      hintStyle: TextStyle(
        color: AppColorsV2.textSecondary,
        fontSize: 14.sp,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      errorStyle: TextStyle(
        color: AppColorsV2.error,
        fontSize: 12.sp,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColorsV2.primary,
        foregroundColor: AppColorsV2.textOnPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        ),
        textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: AppColorsV2.primary,
        side: BorderSide(
          color: AppColorsV2.primary,
          width: 1.5,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        ),
        textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsV2.primary,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: AppColorsV2.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        side: BorderSide(
          color: AppColorsV2.borderLight,
          width: 1,
        ),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.cardMargin,
        vertical: AppSpacing.smVertical,
      ),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColorsV2.borderLight,
      thickness: 1,
      space: 1,
    ),
    
    // Icon Theme
    iconTheme: IconThemeData(
      color: AppColorsV2.textPrimary,
      size: AppSpacing.iconMedium,
    ),
    
    // Splash Color
    splashColor: Colors.transparent,
    highlightColor: AppColorsV2.primary.withOpacity(0.1),
  );
}

