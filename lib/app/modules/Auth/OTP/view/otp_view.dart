import 'package:ustahub/app/export/exports.dart';

class OtpView extends StatelessWidget {
  final String role, email;
  const OtpView({super.key, required this.role, required this.email});

  @override
  Widget build(BuildContext context) {
    print("Role in OtpView: -$role-");
    return Scaffold(
      body: GetBuilder<OtpController>(
        init: Get.put(OtpController()),
        builder: (logic) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.blackText),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  20.ph,
                  Text(
                    AppLocalizations.of(context)!.otpVerify,
                    style: GoogleFonts.ubuntu(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${AppLocalizations.of(context)!.otpVerification} on $email",
                    style: GoogleFonts.ubuntu(
                      fontSize: 14.sp,
                      color: AppColors.grey,
                    ),
                  ),
                  15.ph,
                  Text(
                    AppLocalizations.of(context)!.enterOtp,
                    style: GoogleFonts.ubuntu(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  8.ph,
                  Pinput(
                    length: 6,
                    controller: logic.otpController.value,
                    onTapOutside: (event) {
                      FocusScope.of(Get.context!).unfocus();
                    },
                    onCompleted: (value) {
                      logic.verifyOTP(role: role, email: email);
                    },
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyDecorationWith(
                      border: Border.all(color: AppColors.green),
                    ),
                  ),
                  20.ph,
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppVectors.svgClock,
                        height: 20.h,
                        width: 20.h,
                      ),
                      10.pw,
                      Obx(
                        () => InkWell(
                          onTap:
                              logic.isTimerActive || logic.isResending.value
                                  ? null
                                  : () {
                                    // Trigger actual resend OTP logic
                                    logic.resendOtp();
                                  },
                          child: Text(
                            logic.isResending.value
                                ? "Resending..."
                                : logic.isTimerActive
                                ? "${AppLocalizations.of(context)!.resendIn} ${logic.remainingSeconds}s"
                                : AppLocalizations.of(context)!.resendOtp,
                            style: GoogleFonts.ubuntu(
                              color:
                                  logic.isTimerActive || logic.isResending.value
                                      ? Colors.grey
                                      : AppColors.green,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  200.ph,
                  Obx(()=> logic.isLoading.value ? Center(child: CircularProgressIndicator(),):  BuildBasicButton(
                    onPressed: () {

                      logic.verifyOTP(role: role, email: email);
                      //   Get.to(() => NavBar());
                      // if (role == "consumer") {
                      //   Get.offAll(() => ConsumerProfileSetupView());
                      // } else {
                      //   Get.offAll(() => ProviderServiceSelectionView());
                      //   //
                      // }
                    },
                    title: AppLocalizations.of(context)!.verify,
                  ),)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

final defaultPinTheme = PinTheme(
  margin: EdgeInsets.symmetric(horizontal: 3.w),
  width: 50.h,
  height: 50.h,
  textStyle: GoogleFonts.ubuntu(
    fontSize: 16.sp,
    color: AppColors.blackText,
    fontWeight: FontWeight.w500,
  ),
  decoration: BoxDecoration(
    border: Border.all(color: AppColors.green.withOpacity(0.2)),

    shape: BoxShape.circle,
  ),
);
