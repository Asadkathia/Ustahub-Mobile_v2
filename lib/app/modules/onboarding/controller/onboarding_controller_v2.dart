import 'package:get/get.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/onboarding/model/onboarding_slide_model.dart';
import 'package:ustahub/app/modules/onboarding/repository/onboarding_repository.dart';
import 'package:ustahub/app/modules/location/controller/location_controller.dart';
import 'package:ustahub/utils/assets/app_images.dart';

/// UI v2 Onboarding Controller with location-based image support
class OnboardingControllerV2 extends GetxController {
  final currentIndex = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final slides = <OnboardingSlideModel>[].obs;
  
  // Location-based properties
  final RxString currentCity = ''.obs;
  final RxString currentCountry = ''.obs;

  final PageController pageController = PageController();
  final OnboardingRepository _repository = OnboardingRepository();
  LocationController? _locationController;

  @override
  void onInit() {
    super.onInit();
    // Load slides immediately without waiting for location
    // Location will be used for filtering but won't block initial load
    fetchSlides();
    // Initialize location in background (non-blocking)
    _initializeLocation().then((_) {
      // Refresh slides with location info once available
      if (currentCity.value.isNotEmpty || currentCountry.value.isNotEmpty) {
        fetchSlides();
      }
    });
  }

  /// Initialize location controller and get user's location
  Future<void> _initializeLocation() async {
    try {
      if (!Get.isRegistered<LocationController>()) {
        _locationController = Get.put(LocationController());
      } else {
        _locationController = Get.find<LocationController>();
      }

      // Get current location if available
      final position = await _locationController?.getCurrentLocation();
      if (position != null) {
        await _locationController?.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        currentCity.value = _locationController?.city.value ?? '';
        currentCountry.value = _locationController?.country.value ?? '';
        
        print('[ONBOARDING_V2] 📍 Location detected: ${currentCity.value}, ${currentCountry.value}');
      } else {
        // Fallback: try to get from shared preferences or use default
        print('[ONBOARDING_V2] ⚠️ Location not available, using default');
      }
    } catch (e) {
      print('[ONBOARDING_V2] ❌ Error initializing location: $e');
    }
  }

  /// Fetch onboarding slides with location-based filtering
  Future<void> fetchSlides() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final locale = Get.locale?.languageCode;
      final audience = await Sharedprefhelper.getSharedPrefHelper('userMode');

      // Fetch slides with location information
      final remoteSlides = await _repository.getSlides(
        locale: locale,
        audience: audience,
        city: currentCity.value.isNotEmpty ? currentCity.value : null,
        country: currentCountry.value.isNotEmpty ? currentCountry.value : null,
      );

      if (remoteSlides.isNotEmpty) {
        // Deduplicate slides by image URL to prevent visual duplicates
        final Map<String, OnboardingSlideModel> seenImages = {};
        final List<OnboardingSlideModel> uniqueSlides = [];
        
        for (var slide in remoteSlides) {
          final imageUrl = slide.resolvedImage;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            // Deduplicate by image URL to prevent visual duplicates
            if (!seenImages.containsKey(imageUrl)) {
              seenImages[imageUrl] = slide;
              uniqueSlides.add(slide);
            }
          } else {
            // Include slides without images (they might have different content)
            uniqueSlides.add(slide);
          }
        }
        
        slides.assignAll(uniqueSlides);
        print('[ONBOARDING_V2] ✅ Loaded ${uniqueSlides.length} unique slides (from ${remoteSlides.length} total)');
      } else {
        print('[ONBOARDING_V2] ⚠️ No remote slides found, using fallback');
        slides.assignAll(_fallbackSlides());
      }
    } catch (e) {
      print('[ONBOARDING_V2] ❌ Error fetching slides: $e');
      errorMessage.value = e.toString();
      slides.assignAll(_fallbackSlides());
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh slides (useful after location changes)
  Future<void> refreshSlides() async {
    await _initializeLocation();
    await fetchSlides();
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

