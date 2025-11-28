import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/onboarding/view/onboarding_view.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/app/ui_v2/screens/onboarding/onboarding_screen_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../components/buttons/primary_button.dart';

class LoginRequiredScreenV2 extends StatelessWidget {
  final String feature;
  
  const LoginRequiredScreenV2({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Large Teal Circular Icon
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppColorsV2.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColorsV2.textOnPrimary,
                        size: AppSpacing.iconXLarge,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xlVertical),
                    // Title
                    Text(
                      "Login Required",
                      style: AppTextStyles.heading2,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.mdVertical),
                    // Description
                    Text(
                      "Please login to access $feature features",
                      style: AppTextStyles.bodyMediumSecondary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xlVertical),
                    // Login Now Button
                    PrimaryButton(
                      text: "Login Now",
                      onPressed: () {
                        if (UIConfig.useNewOnboarding) {
                          Get.offAll(() => OnboardingScreenV2());
                        } else {
                          Get.offAll(() => OnboardingView());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Note: Bottom navigation bar is provided by NavBarV2, don't add it here
        ],
      ),
    );
  }
}

