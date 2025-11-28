import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/onboarding/model/onboarding_slide_model.dart';
import 'package:ustahub/app/modules/onboarding/repository/onboarding_repository.dart';
import 'package:ustahub/utils/assets/app_images.dart';

class OnboardingController extends GetxController {
  final currentIndex = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final slides = <OnboardingSlideModel>[].obs;

  final PageController pageController = PageController();
  final OnboardingRepository _repository = OnboardingRepository();

  @override
  void onInit() {
    super.onInit();
    fetchSlides();
  }

  Future<void> fetchSlides() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final locale = Get.locale?.languageCode;
      final audience = await Sharedprefhelper.getSharedPrefHelper('userMode');

      final remoteSlides = await _repository.getSlides(
        locale: locale,
        audience: audience,
      );

      if (remoteSlides.isNotEmpty) {
        slides.assignAll(remoteSlides);
      } else {
        slides.assignAll(_fallbackSlides());
      }
    } catch (e) {
      errorMessage.value = e.toString();
      slides.assignAll(_fallbackSlides());
    } finally {
      isLoading.value = false;
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void goToNextPage() {
    if (slides.isEmpty) return;
    if (currentIndex.value < slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  OnboardingSlideModel? slideAt(int index) {
    if (index < 0 || index >= slides.length) return null;
    return slides[index];
  }

  List<OnboardingSlideModel> _fallbackSlides() {
    return [
      OnboardingSlideModel(
        id: 'local-1',
        title: 'Trusted Local Experts',
        subtitle: 'Trusted Local Experts, Just a Tap Away',
        imageOverride: AppImages.onboarding1,
        displayOrder: 0,
      ),
      OnboardingSlideModel(
        id: 'local-2',
        title: 'Services Catalog',
        subtitle: '42+ local services\n200+ service providers',
        imageOverride: AppImages.onboarding2,
        displayOrder: 1,
      ),
      OnboardingSlideModel(
        id: 'local-3',
        title: 'We are Global',
        subtitle:
            'We are present in: \n🇬🇪 Georgian\n🇦🇲 Armenian\n🇬🇧 English\n🇸🇦 Arabic\n🇺🇿 Uzbek\n🇷🇺 Russian\n🇰🇿 Kazak',
        imageOverride: 'assets/images/onboarding3.png',
        displayOrder: 2,
      ),
    ];
  }
}
