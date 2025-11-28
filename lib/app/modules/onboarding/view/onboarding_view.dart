// onboarding_view.dart
import 'package:ustahub/app/modules/Auth/login/view/login_view.dart';
import 'package:ustahub/app/modules/onboarding/controller/onboarding_controller.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';

class OnboardingView extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());

  OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40.h),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: controller.goToNextPage,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.next,
                    style: GoogleFonts.ubuntu(
                      color: Colors.green,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ),
            10.ph,
            Text(
              AppLocalizations.of(context)!.welcomeText,
              style: GoogleFonts.ubuntu(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.slides.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.slides.isEmpty) {
                  return Center(
                    child: Text(
                      'No onboarding content available yet.',
                      style: GoogleFonts.ubuntu(
                        fontSize: 16.sp,
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.slides.length,
                  itemBuilder: (_, index) {
                    final slide = controller.slideAt(index);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        20.ph,
                        Text(
                          slide?.subtitle ?? '',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.ubuntu(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey,
                          ),
                        ),
                        80.ph,
                        _OnboardingImage(imagePath: slide?.resolvedImage),
                        index == 0 ? 30.ph : 50.ph,
                        Obx(() {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              controller.slides.length,
                              (dotIndex) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                height: 8.h,
                                width: controller.currentIndex.value == dotIndex
                                    ? 20.w
                                    : 8.w,
                                decoration: BoxDecoration(
                                  color:
                                      controller.currentIndex.value == dotIndex
                                          ? Colors.green
                                          : Colors.grey,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 20.h),
            BuildBasicButton(
              title: AppLocalizations.of(context)!.continueAsService,
              onPressed: () async {
                await Sharedprefhelper.setSharedPrefHelper('hasSeenOnboarding', 'true');
                await Sharedprefhelper.setSharedPrefHelper('userMode', 'provider');
                Get.offAll(() => LoginView(role: "provider"));
              },
              buttonColor: Colors.white,
              textStyle: GoogleFonts.ubuntu(
                color: AppColors.green,
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 20.h),
            BuildBasicButton(
              title: AppLocalizations.of(context)!.continueAsConsumer,
              onPressed: () async {
                await Sharedprefhelper.setSharedPrefHelper('hasSeenOnboarding', 'true');
                await Sharedprefhelper.setSharedPrefHelper('userMode', 'consumer');
                Get.to(() => LoginView(role: "consumer"));
              },
              buttonColor: AppColors.green,
              textStyle: GoogleFonts.ubuntu(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 15.h),
            GestureDetector(
              onTap: () async {
                await Sharedprefhelper.setSharedPrefHelper('hasSeenOnboarding', 'true');
                await Sharedprefhelper.setSharedPrefHelper('userMode', 'guest');
                AppRouterV2.goToNavBar(role: 'guest');
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                child: Center(
                  child: Text(
                    "Continue as Guest",
                    style: GoogleFonts.ubuntu(
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _OnboardingImage extends StatelessWidget {
  final String? imagePath;

  const _OnboardingImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return SizedBox(height: 150.h);
    }

    final isNetwork = imagePath!.startsWith('http');
    final imageWidget = isNetwork
        ? Image.network(
            imagePath!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
          )
        : Image.asset(
            imagePath!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
          );

    return SizedBox(
      height: 250.h,
      width: 300.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: imageWidget,
      ),
    );
  }
}
