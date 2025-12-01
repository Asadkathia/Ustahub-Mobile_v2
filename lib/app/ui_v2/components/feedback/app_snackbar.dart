import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class AppSnackbar {
  const AppSnackbar._();

  static void success(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      background: AppColorsV2.success,
      textColor: AppColorsV2.textOnPrimary,
    );
  }

  static void error(String message, {String title = 'Oops'}) {
    _show(
      title: title,
      message: message,
      background: AppColorsV2.error,
      textColor: AppColorsV2.textOnPrimary,
    );
  }

  static void info(String message, {String title = 'Info'}) {
    _show(
      title: title,
      message: message,
      background: AppColorsV2.info,
      textColor: AppColorsV2.textOnPrimary,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color background,
    required Color textColor,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: background,
      colorText: textColor,
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
        vertical: AppSpacing.smVertical,
      ),
      borderRadius: AppSpacing.radiusLarge,
      duration: const Duration(seconds: 3),
      icon: Icon(
        Icons.info_outline,
        color: textColor,
      ),
      titleText: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: textColor),
      ),
    );
  }
}

