import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/location/controller/location_controller.dart';

class BannerController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<BannerModelClass> bannersList = <BannerModelClass>[].obs;
  
  // Location-based properties
  final RxString currentCity = ''.obs;
  final RxString currentCountry = ''.obs;

  final _repository = BannerRepository();
  LocationController? _locationController;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _initializeLocation();
    await getBanners();
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
        
        print('[BANNER] 📍 Location detected: ${currentCity.value}, ${currentCountry.value}');
      } else {
        print('[BANNER] ⚠️ Location not available, using default');
      }
    } catch (e) {
      print('[BANNER] ❌ Error initializing location: $e');
    }
  }

  Future<void> getBanners() async {
    try {
      isLoading.value = true;

      final response = await _repository.getBanners(
        city: currentCity.value.isNotEmpty ? currentCity.value : null,
        country: currentCountry.value.isNotEmpty ? currentCountry.value : null,
      );

      if (response['statusCode'] == 200 &&
          response['body']?['status'] == true) {
        final List<dynamic> data =
            response['body']?['data'] as List<dynamic>? ?? [];
        bannersList.value = data
            .map(
              (json) =>
                  BannerModelClass.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        print('[BANNER] ✅ Loaded ${bannersList.length} banners');
      } else {
        print('Failed to load banners: ${response['body']}');
      }
    } catch (e) {
      print('Error loading banners: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBanners() async {
    await _initializeLocation();
    await getBanners();
  }
}
