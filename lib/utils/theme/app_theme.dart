import 'package:ustahub/app/export/exports.dart';

class AppTheme {
  static final appTheme = ThemeData(
    brightness: Brightness.light,

    primaryColor: AppColors.green,
    scaffoldBackgroundColor: AppColors.background,
    splashColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      shadowColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.blackText),
    ),
    textTheme: GoogleFonts.ubuntuTextTheme().copyWith(
      headlineMedium: TextStyle(
        color: AppColors.blackText,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: AppColors.grey),
      bodyMedium: TextStyle(color: AppColors.blackText),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightGreen,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.lightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.green),
      ),
      hintStyle: TextStyle(color: AppColors.grey),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14),
        textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    ),
  );

  static TextStyle get whiteText => GoogleFonts.ubuntu(color: AppColors.white);
  static TextStyle get blackText => GoogleFonts.ubuntu(color: AppColors.blackText);
}
