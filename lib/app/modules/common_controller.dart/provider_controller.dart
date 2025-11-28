import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/common_model_class/ProviderListModelClass.dart';
import 'package:ustahub/app/modules/location/controller/location_controller.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class ProviderController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<ProvidersListModelClass> providersList =
      <ProvidersListModelClass>[].obs;

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
      print("📍 Location initialized: ${locationController.latitude.value}, ${locationController.longitude.value}");
    } catch (e) {
      _locationInitialized = true; // Mark as initialized even if failed
      print("⚠️ Location initialization error (will continue without location): $e");
    }
  }

  /// Ensure location is initialized before fetching providers
  Future<void> _ensureLocationInitialized() async {
    if (!_locationInitialized) {
      print("⏳ Waiting for location initialization...");
      await initializeLocation();
    }
  }

  final _api = SupabaseApiServices();
  
  Future<void> getProvider({String? serviceId, String? top}) async {
    print("[PROVIDERS] Fetching providers...");
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
        print("[PROVIDERS] ✅ Loaded ${providersList.length} providers");
      } else {
        print("[PROVIDERS] ❌ Failed: ${response['body']}");
      }
    } catch (e) {
      print("[PROVIDERS] ❌ Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh providers with updated location
  Future<void> refreshProvidersWithLocation({String? serviceId}) async {
    try {
      print("🔄 Refreshing location and providers...");
      await locationController.getCurrentLocationAndAddress();
      print("📍 Location updated: ${locationController.latitude.value}, ${locationController.longitude.value}");
      await getProvider(serviceId: serviceId);
    } catch (e) {
      print("⚠️ Location refresh error: $e");
      // Still try to get providers even if location fails
      await getProvider(serviceId: serviceId);
    }
  }

  // ✅ Search providers
  Future<void> searchProviders({required String keyword}) async {
    print("[PROVIDERS] Searching with keyword: $keyword");
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
        print("[PROVIDERS] ✅ Found ${providersList.length} providers");
      } else {
        print("[PROVIDERS] ❌ Search failed: ${response['body']}");
      }
    } catch (e) {
      print("[PROVIDERS] ❌ Search error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
