import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/Auth/login/view/login_view.dart';
import '../../config/ui_config.dart';
import '../../screens/auth/login/login_screen_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../components/buttons/primary_button_v2.dart';
import '../../components/buttons/secondary_button_v2.dart';
import '../../components/buttons/text_button_v2.dart';
import '../../components/navigation/app_app_bar_v2.dart';

class GuestAccountScreenV2 extends StatelessWidget {
  const GuestAccountScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.account,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  // Avatar Placeholder
                  CircleAvatar(
                    radius: 60.r,
                    backgroundColor: AppColorsV2.textSecondary.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 60.sp,
                      color: AppColorsV2.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Guest User Text
                  Text(
                    "Guest User",
                    style: AppTextStyles.heading2,
                  ),
                  SizedBox(height: 8.h),
                  // Subtitle
                  Text(
                    "Create an account to access all features",
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48.h),
                  // Login as Service Provider Button
                  SecondaryButtonV2(
                    text: "Login as a service provider",
                    onPressed: () {
                      if (UIConfig.useNewLogin) {
                        Get.offAll(() => LoginScreenV2(role: "provider"));
                      } else {
                        Get.offAll(() => LoginView(role: "provider"));
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Login as Consumer Button
                  PrimaryButtonV2(
                    text: "Login as a Consumer",
                    onPressed: () {
                      if (UIConfig.useNewLogin) {
                        Get.offAll(() => LoginScreenV2(role: "consumer"));
                      } else {
                        Get.offAll(() => LoginView(role: "consumer"));
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  // Back Link
                  TextButtonV2(
                    text: "Back",
                    onPressed: () => Get.back(),
                    textColor: AppColorsV2.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

