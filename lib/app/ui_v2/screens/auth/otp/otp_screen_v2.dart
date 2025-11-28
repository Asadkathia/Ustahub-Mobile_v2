import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/Auth/OTP/controller/otp_controller.dart';
import 'package:ustahub/app/modules/onboarding/view/onboarding_view.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/app/ui_v2/screens/onboarding/onboarding_screen_v2.dart';
import 'package:pinput/pinput.dart';
import '../../../design_system/colors/app_colors_v2.dart';
import '../../../design_system/typography/app_text_styles.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../components/buttons/primary_button.dart';

class OtpScreenV2 extends StatelessWidget {
  final String role;
  final String email;
  
  const OtpScreenV2({
    super.key,
    required this.role,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      body: GetBuilder<OtpController>(
        init: () {
          final controller = Get.put(OtpController());
          controller.setCredentials(email, role);
          return controller;
        }(),
        builder: (logic) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.screenPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 60.h),
                        // Title
                        Text(
                          AppLocalizations.of(context)!.otpVerify,
                          style: AppTextStyles.heading2,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.smVertical),
                        // Subtitle
                        Text(
                          "${AppLocalizations.of(context)!.otpVerification} $email",
                          style: AppTextStyles.bodyMediumSecondary,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.xlVertical),
                        // Code Input Field - Using Pinput for compatibility with existing controller
                        Pinput(
                          length: 6,
                          controller: logic.otpController.value,
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                          },
                          onCompleted: (value) {
                            logic.verifyOTP(role: role, email: email);
                          },
                          defaultPinTheme: PinTheme(
                            width: 60.w,
                            height: 60.h,
                            textStyle: AppTextStyles.heading3.copyWith(
                              fontSize: 24.sp,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorsV2.background,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                              border: Border.all(
                                color: AppColorsV2.borderLight,
                                width: 1,
                              ),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 60.w,
                            height: 60.h,
                            textStyle: AppTextStyles.heading3.copyWith(
                              fontSize: 24.sp,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorsV2.background,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                              border: Border.all(
                                color: AppColorsV2.borderFocus,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lgVertical),
                        // Verify Button
                        Obx(
                          () => PrimaryButton(
                            text: logic.isLoading.value
                                ? "Verifying..."
                                : AppLocalizations.of(context)!.verify,
                            onPressed: logic.isLoading.value
                                ? null
                                : () {
                                    if (logic.otpController.value.text.length == 6) {
                                      logic.verifyOTP(role: role, email: email);
                                    }
                                  },
                            isLoading: logic.isLoading.value,
                          ),
                        ),
                        SizedBox(height: AppSpacing.mdVertical),
                        // Resend OTP
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: AppSpacing.iconSmall,
                                color: logic.isTimerActive || logic.isResending.value
                                    ? AppColorsV2.textSecondary
                                    : AppColorsV2.primary,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              GestureDetector(
                                onTap: logic.isTimerActive || logic.isResending.value
                                    ? null
                                    : () {
                                        logic.resendOtp();
                                      },
                                child: Text(
                                  logic.isResending.value
                                      ? "Resending..."
                                      : logic.isTimerActive
                                          ? "${AppLocalizations.of(context)!.resendIn} ${logic.remainingSeconds.value}s"
                                          : AppLocalizations.of(context)!.resendOtp,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: logic.isTimerActive || logic.isResending.value
                                        ? AppColorsV2.textSecondary
                                        : AppColorsV2.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.mdVertical),
                        // Back Link
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Text(
                            "Back",
                            style: AppTextStyles.bodyMediumSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

