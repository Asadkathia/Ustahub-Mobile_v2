import 'dart:ui';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/onboarding/controller/onboarding_controller_v2.dart';
import 'package:ustahub/app/modules/onboarding/model/onboarding_slide_model.dart';
import 'package:ustahub/app/modules/Auth/login/view/login_view.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';
import 'package:ustahub/app/ui_v2/screens/auth/login/login_screen_v2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../components/buttons/primary_button.dart';
import '../../components/buttons/outlined_button.dart' as outlined;

class OnboardingScreenV2 extends StatelessWidget {
  final OnboardingControllerV2 controller = Get.put(OnboardingControllerV2());

  OnboardingScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    print("[ONBOARDING_V2] Building OnboardingScreenV2 with new UI");
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.slides.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.slides.isEmpty) {
          return _buildEmptyState(context);
        }

        return Stack(
          children: [
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.slides.length,
              itemBuilder: (context, index) {
                final slide = controller.slideAt(index);
                if (slide == null) return const SizedBox.shrink();
                return _buildSlide(slide);
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomPanel(context),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSlide(OnboardingSlideModel slide) {
    final imagePath = slide.resolvedImage;
    final isNetwork = imagePath != null && imagePath.startsWith('http');

    return Builder(
      builder: (context) {
        return Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null && imagePath.isNotEmpty)
              (isNetwork
                  ? CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.1, 0),
                      placeholder: (context, url) => Container(
                        color: AppColorsV2.primary,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColorsV2.textOnPrimary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildImageFallback(imagePath),
                      memCacheWidth: (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).round(),
                      memCacheHeight: (MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio).round(),
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.1, 0),
                      errorBuilder: (_, __, ___) => _buildImageFallback(imagePath),
                    ))
            else
              _buildImageFallback(imagePath),
            Positioned(
              bottom: 200.h,
              left: 0,
              right: 0,
              child: Obx(() => _buildPaginationDots()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.slides.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: controller.currentIndex.value == index ? 24.w : 8.w,
          decoration: BoxDecoration(
            color: controller.currentIndex.value == index
                ? AppColorsV2.textOnPrimary
                : AppColorsV2.textOnPrimary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  Widget _buildImageFallback(String? path) {
    return Container(
      color: AppColorsV2.primary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: AppColorsV2.textOnPrimary,
              size: 100.w,
            ),
            SizedBox(height: 16.h),
            Text(
              'Image unavailable',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColorsV2.textOnPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (path != null)
              Text(
                path,
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColorsV2.textOnPrimary.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      color: AppColorsV2.background,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 72.w,
            color: AppColorsV2.textSecondary,
          ),
          SizedBox(height: AppSpacing.mdVertical),
          Text(
            'No onboarding content available yet.',
            style: AppTextStyles.heading3.copyWith(color: AppColorsV2.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.mdVertical),
          TextButton(
            onPressed: controller.fetchSlides,
            child: Text(
              'Retry',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColorsV2.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXLarge),
          topRight: Radius.circular(AppSpacing.radiusXLarge),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
        vertical: AppSpacing.mdVertical,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // USTAHUB Logo - constrained container with overflow allowed
          SizedBox(
            height: 80.h,
            child: OverflowBox(
              maxHeight: double.infinity,
              alignment: Alignment.center,
              child: Image.asset(
                'images/Logo/Ustahub logo copy.png',
                height: 140.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'USTAHUB',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColorsV2.primary,
                      letterSpacing: 1.2,
                      fontSize: 40.sp,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: AppSpacing.mdVertical),
          // Continue as Service Provider Button (Outlined)
          outlined.AppOutlinedButton(
            text: AppLocalizations.of(context)!.continueAsService,
            onPressed: () async {
              await Sharedprefhelper.setSharedPrefHelper('hasSeenOnboarding', 'true');
              await Sharedprefhelper.setSharedPrefHelper('userMode', 'provider');
              // Always use V2 login
              Get.offAll(() => LoginScreenV2(role: "provider"));
            },
          ),
          SizedBox(height: AppSpacing.mdVertical),
          // Continue as Consumer Button (Primary)
          PrimaryButton(
            text: AppLocalizations.of(context)!.continueAsConsumer,
            onPressed: () async {
              await Sharedprefhelper.setSharedPrefHelper('hasSeenOnboarding', 'true');
              await Sharedprefhelper.setSharedPrefHelper('userMode', 'consumer');
              // Always use V2 login
              Get.offAll(() => LoginScreenV2(role: "consumer"));
            },
          ),
          SizedBox(height: AppSpacing.mdVertical),
          // Continue as Guest Link
          GestureDetector(
            onTap: () async {
              await Sharedprefhelper.setSharedPrefHelper('hasSeenOnboarding', 'true');
              await Sharedprefhelper.setSharedPrefHelper('userMode', 'guest');
              AppRouterV2.goToNavBar(role: "guest");
            },
            child: Text(
              "Continue as a Guest",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColorsV2.textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.mdVertical),
        ],
      ),
    );
  }
}

