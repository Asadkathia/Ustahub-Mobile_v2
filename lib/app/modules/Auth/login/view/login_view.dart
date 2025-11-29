import 'package:ustahub/app/export/exports.dart';

class LoginView extends StatelessWidget {
  final String role;
  LoginView({super.key, required this.role});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<LoginController>(
        init: Get.put(LoginController()),
        builder: (logic) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  30.ph,
                  Text(
                    AppLocalizations.of(context)!.enterYourEmail,
                    style: GoogleFonts.ubuntu(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.weWillSendYou,
                    style: GoogleFonts.ubuntu(
                      fontSize: 14.sp,
                      color: AppColors.grey,
                    ),
                  ),
                  30.ph,
                  Obx(
                    () => Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32.r),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          TabButton(
                            label: AppLocalizations.of(context)!.email,
                            isSelected: logic.isEmailSelected.value,
                            onTap: () => logic.toggle(true),
                          ),
                          // TabButton(
                          //   label: AppLocalizations.of(context)!.phone,
                          //   isSelected: !logic.isEmailSelected.value,
                          //   onTap: () => logic.toggle(false),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  15.ph,
                  Obx(
                    () => Form(
                      key: _formKey,
                      child:
                          !logic.isEmailSelected.value
                              ? InternationalPhoneNumberInput(
                                validator: (val) {
                                  if (val == null) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterYourPhone;
                                  }
                                  String onlyDigits = val.replaceAll(
                                    RegExp(r'\D'),
                                    '',
                                  );

                                  if (onlyDigits.length < 9) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.phoneIsTooShort;
                                  } else if (onlyDigits.length > 11) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.phoneIsTooLong;
                                  }

                                  return null;
                                },
                                onInputChanged: (val) {},
                                selectorConfig: const SelectorConfig(
                                  selectorType: PhoneInputSelectorType.DROPDOWN,
                                ),
                                spaceBetweenSelectorAndTextField: 0,

                                inputDecoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.green.withOpacity(0.1),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.green.withOpacity(0.1),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.green,
                                      width: 1.2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.h,
                                  ),
                                ),
                                inputBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.green.withAlpha(10),
                                    width: 1,
                                  ),
                                ),
                                initialValue: PhoneNumber(isoCode: "UZ"),
                              )
                              : buildFormField(
                                controller: logic.emailController.value,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.enterYourEmail;
                                  }

                                  // Simple email regex
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );

                                  if (!emailRegex.hasMatch(val.trim())) {
                                    return AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterValidEmail;
                                  }

                                  return null;
                                },

                                hint:
                                    AppLocalizations.of(
                                      context,
                                    )!.pleasEnterEmail,
                              ),
                    ),
                  ),
                  50.ph,
                  Obx(
                    () =>
                        logic.isLoading.value
                            ? Center(
                              child: CircularProgressIndicator(
                                color: AppColors.green,
                              ),
                            )
                            : Obx(
                              () => BuildBasicButton(
                                onPressed:
                                    logic.isOtpSending.value
                                        ? () {} // Empty function when loading
                                        : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            logic.sendOtpToEmail(role);
                                          }
                                        },
                                title:
                                    logic.isOtpSending.value
                                        ? "Sending OTP..."
                                        : AppLocalizations.of(context)!.getOtp,
                              ),
                            ),
                  ),
                  30.ph,
                  // Divider with "OR" text
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.grey.withOpacity(0.3))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          "OR",
                          style: GoogleFonts.ubuntu(
                            fontSize: 14.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.grey.withOpacity(0.3))),
                    ],
                  ),
                  30.ph,
                  // Google Sign-In Button
                  Obx(
                    () => BuildBasicButton(
                      buttonColor: Colors.white,
                      onPressed: logic.isGoogleSigningIn.value
                          ? () {} // Disable when loading
                          : () {
                              logic.signInWithGoogle(role);
                            },
                      title: logic.isGoogleSigningIn.value
                          ? "Signing in..."
                          : AppLocalizations.of(context)!.loginGoogle,
                      textStyle: GoogleFonts.ubuntu(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      icon: SvgPicture.asset(
                        height: 24.h,
                        width: 24.w,
                        AppVectors.svgGoogle,
                      ),
                    ),
                  ),
                  20.ph,
                  // Platform.isIOS
                  //     ? BuildBasicButton(
                  //       buttonColor: Colors.white,
                  //       onPressed: () {},
                  //       title: AppLocalizations.of(context)!.loginApple,
                  //       textStyle: GoogleFonts.ubuntu(
                  //         color: Colors.black,
                  //         fontSize: 16.sp,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //       icon: SvgPicture.asset(
                  //         height: 24.h,
                  //         width: 24.w,
                  //         AppVectors.svgApple,
                  //       ),
                  //     )
                  //     : SizedBox.shrink(),
                  Spacer(),
                  TermsAndPrivacyPolicyText(),
                  20.ph,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
