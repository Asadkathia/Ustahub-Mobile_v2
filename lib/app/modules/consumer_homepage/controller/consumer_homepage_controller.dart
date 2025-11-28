import 'package:ustahub/app/export/exports.dart';

class ConsumerHomepageController extends GetxController {
  var currentIndex = 0.obs;

  void updateIndex(int index) {
    currentIndex.value = index;
  }

  final servicesController = Get.put(ProviderServiceSelectionController());
  final providerController = Get.find<ProviderController>();
  final bannerController = Get.put(BannerController());
  final consumerProfile = Get.find<ConsumerProfileController>();
  final providerProfile = Get.find<ProviderProfileController>();

  final favouriteProvider = Get.put(FavouriteProviderController());

  Future<String?> getRole() async {
    String? role = await Sharedprefhelper.getRole();
    return role;
  }

  @override
  void onInit() async {
    super.onInit();
    // Initialize controllers and fetch data
    if (await getRole() == "provider") {
      await providerProfile.fetchProfile();
    } else {
      await consumerProfile.fetchProfile();
    }
    
    // Fetch top providers for homepage (location will be ensured in getProvider)
    providerController.getProvider(top: '1');
  }

  // Refresh all data on homepage
  Future<void> refreshHomepage() async {
    try {
      // Refresh banners
      await bannerController.refreshBanners();

      // Refresh services
      servicesController.getServices();

      // Refresh top providers for homepage
      providerController.getProvider(top: '1');

      // Refresh user profile based on role
      final role = await getRole();
      if (role == "provider") {
        await providerProfile.fetchProfile();
      } else {
        await consumerProfile.fetchProfile();
      }
    } catch (e) {
      print('Error refreshing homepage: $e');
    }
  }
}
