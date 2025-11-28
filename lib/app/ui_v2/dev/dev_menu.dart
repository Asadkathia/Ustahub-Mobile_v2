import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustahub/app/export/exports.dart';
import '../screens/splash/splash_screen_v2.dart';
import '../screens/onboarding/onboarding_screen_v2.dart';
import '../screens/auth/login/login_screen_v2.dart';
import '../screens/account/guest_account_screen_v2.dart';
import '../screens/navigation/nav_bar_v2.dart';
import '../design_system/colors/app_colors_v2.dart';
import '../design_system/typography/app_text_styles.dart';
import '../design_system/spacing/app_spacing.dart';

class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dev Menu - New UI',
          style: AppTextStyles.heading3,
        ),
        backgroundColor: AppColorsV2.background,
      ),
      backgroundColor: AppColorsV2.background,
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text(
            'New UI Screens',
            style: AppTextStyles.heading2,
          ),
          SizedBox(height: AppSpacing.lg),
          _buildMenuItem(
            context,
            'Splash Screen V2',
            'New splash screen with USTAHUB logo and progress bar',
            () => Get.to(() => const SplashScreenV2()),
          ),
          _buildMenuItem(
            context,
            'Onboarding Screen V2',
            'New onboarding with gradient headers and blurred backgrounds',
            () => Get.to(() => OnboardingScreenV2()),
          ),
          _buildMenuItem(
            context,
            'Login Screen V2 (Consumer)',
            'New login screen for consumer',
            () => Get.to(() => LoginScreenV2(role: "consumer")),
          ),
          _buildMenuItem(
            context,
            'Login Screen V2 (Provider)',
            'New login screen for provider',
            () => Get.to(() => LoginScreenV2(role: "provider")),
          ),
          _buildMenuItem(
            context,
            'Guest Account Screen V2',
            'New guest account screen',
            () => Get.to(() => const GuestAccountScreenV2()),
          ),
          _buildMenuItem(
            context,
            'Nav Bar V2 (Consumer)',
            'New navigation bar with consumer role',
            () => Get.offAll(() => NavBarV2(role: "consumer", initialIndex: 0)),
          ),
          _buildMenuItem(
            context,
            'Nav Bar V2 (Provider)',
            'New navigation bar with provider role',
            () => Get.offAll(() => NavBarV2(role: "provider", initialIndex: 0)),
          ),
          _buildMenuItem(
            context,
            'Nav Bar V2 (Guest)',
            'New navigation bar with guest role',
            () => Get.offAll(() => NavBarV2(role: "guest", initialIndex: 0)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: AppColorsV2.primary,
        ),
        onTap: onTap,
      ),
    );
  }
}

