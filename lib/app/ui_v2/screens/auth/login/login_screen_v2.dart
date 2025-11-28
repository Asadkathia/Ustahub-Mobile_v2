import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/Auth/login/controller/login_controller.dart';
import 'package:ustahub/app/modules/onboarding/view/onboarding_view.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/app/ui_v2/screens/onboarding/onboarding_screen_v2.dart';
import '../../../design_system/colors/app_colors_v2.dart';
import '../../../design_system/typography/app_text_styles.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/inputs/app_text_field.dart';

class LoginScreenV2 extends StatelessWidget {
  final String role;
  LoginScreenV2({super.key, required this.role});
  
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    print("[LOGIN_V2] Building LoginScreenV2 with new UI");
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      body: GetBuilder<LoginController>(
        init: Get.put(LoginController()),
        builder: (logic) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.screenPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 60.h),
                          // Title
                          Text(
                            AppLocalizations.of(context)!.enterYourEmail,
                            style: AppTextStyles.heading2,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.smVertical),
                          // Subtitle
                          Text(
                            AppLocalizations.of(context)!.weWillSendYou,
                            style: AppTextStyles.bodyMediumSecondary,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.xlVertical),
                          // Email Input Field
                          AppTextField(
                            controller: logic.emailController.value,
                            hintText: AppLocalizations.of(context)!.email,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColorsV2.textSecondary,
                              size: AppSpacing.iconMedium,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return AppLocalizations.of(context)!.pleasEnterEmail;
                              }
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(val.trim())) {
                                return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lgVertical),
                          // Get OTP Button
                          Obx(
                            () => PrimaryButton(
                              text: logic.isOtpSending.value
                                  ? "Sending OTP..."
                                  : AppLocalizations.of(context)!.getOtp,
                              onPressed: logic.isOtpSending.value
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        logic.sendOtpToEmail(role);
                                      }
                                    },
                              isLoading: logic.isOtpSending.value,
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
                          SizedBox(height: AppSpacing.xlVertical),
                          // Terms and Privacy Policy
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenPaddingHorizontal,
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: AppTextStyles.bodySmall,
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.termsFirstLine,
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.termsSecondLine,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColorsV2.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.termsThirdLine,
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.termsFourthLine,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColorsV2.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

