import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/common_model_class/ProviderListModelClass.dart';
import 'package:ustahub/app/modules/location/controller/location_controller.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class ProviderController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<ProvidersListModelClass> providersList =
      <ProvidersListModelClass>[].obs;

  /// Get top N providers (optimized for homepage)
  /// Pre-computes reversed list to avoid repeated operations in UI
  List<ProvidersListModelClass> getTopProviders(int count) {
    final reversed = providersList.reversed.toList();
    return reversed.take(count).toList();
  }

  late LocationController locationController;
  bool _locationInitialized = false;

  // ✅ Initial fetch
  @override
  void onInit() {
    super.onInit();
    // Initialize location controller
    if (!Get.isRegistered<LocationController>()) {
      locationController = Get.put(LocationController());
    } else {
      locationController = Get.find<LocationController>();
    }
    // Initialize location in background, but don't fetch providers yet
    // Providers will be fetched when explicitly called (e.g., from homepage)
    initializeLocation();
  }

  /// Initialize location without fetching providers
  Future<void> initializeLocation() async {
    try {
      await locationController.getCurrentLocationAndAddress();
      _locationInitialized = true;
    } catch (e) {
      _locationInitialized = true; // Mark as initialized even if failed
    }
  }

  /// Ensure location is initialized before fetching providers
  Future<void> _ensureLocationInitialized() async {
    if (!_locationInitialized) {
      await initializeLocation();
    }
  }

  final _api = SupabaseApiServices();
  
  Future<void> getProvider({String? serviceId, String? top}) async {
    // Ensure location is initialized before fetching
    await _ensureLocationInitialized();
    isLoading.value = true;

    try {
      // Use Supabase to get providers
      // Don't use limit parameter - fetch all providers
      final response = await _api.getProviders(
        serviceId: serviceId,
        limit: 50, // Always fetch up to 50 providers for homepage
      );

      if (response['statusCode'] == 200 && response['body']['data'] != null) {
        final data = response['body']['data'] as List;
        providersList.value =
            data.map((e) => ProvidersListModelClass.fromJson(e)).toList();
      }
    } catch (e) {
      // Error handling - could use logger here
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh providers with updated location
  Future<void> refreshProvidersWithLocation({String? serviceId}) async {
    try {
      await locationController.getCurrentLocationAndAddress();
      await getProvider(serviceId: serviceId);
    } catch (e) {
      // Still try to get providers even if location fails
      await getProvider(serviceId: serviceId);
    }
  }

  // ✅ Search providers
  Future<void> searchProviders({required String keyword}) async {
    isLoading.value = true;

    try {
      // Use Supabase search
      final response = await _api.getProviders(
        searchTerm: keyword,
      );

      if (response['statusCode'] == 200 && response['body']['data'] != null) {
        final data = response['body']['data'] as List;
        providersList.value =
            data.map((e) => ProvidersListModelClass.fromJson(e)).toList();
      }
    } catch (e) {
      // Error handling
    } finally {
      isLoading.value = false;
    }
  }

  // Advanced search with filters
  Future<void> advancedSearchProviders({
    String? keyword,
    String? serviceId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? maxDistance,
    String? sortBy,
    bool? verifiedOnly,
    bool? availableToday,
  }) async {
    isLoading.value = true;

    try {
      await _ensureLocationInitialized();
      
      double? latitude;
      double? longitude;
      if (locationController.latitude.value != 0.0 && locationController.longitude.value != 0.0) {
        latitude = locationController.latitude.value;
        longitude = locationController.longitude.value;
      }

      final response = await _api.getProviders(
        serviceId: serviceId,
        searchTerm: keyword,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        maxDistance: maxDistance,
        latitude: latitude,
        longitude: longitude,
        sortBy: sortBy,
        verifiedOnly: verifiedOnly,
        availableToday: availableToday,
      );

      if (response['statusCode'] == 200 && response['body']['data'] != null) {
        final data = response['body']['data'] as List;
        providersList.value =
            data.map((e) => ProvidersListModelClass.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[PROVIDER_CONTROLLER] Advanced search error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
