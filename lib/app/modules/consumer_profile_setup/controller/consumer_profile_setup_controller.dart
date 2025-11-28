import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/consumer_profile_setup/repository/consumer_profile_setup_repository.dart';
import 'package:ustahub/app/modules/location/controller/location_controller.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';

class ConsumerProfileSetupController extends GetxController {
  final Rx<File?> pickedImage = Rx<File?>(null);
  var selectedCountry = ''.obs;
  final flatHouseController = TextEditingController();
  final pinCodeController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final nameController = TextEditingController();

  final RxString currentAddress = "".obs;
  final RxBool isLoading = false.obs;
  final RxBool isLocationFetching = false.obs;
  RxString profileImageURL = "".obs;

  // Location controller instance
  late LocationController locationController;

  final uploadFileController = Get.put(UploadFile());

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedImage.value = File(image.path);
      profileImageURL.value =
          await uploadFileController.uploadFile(
            file: File(image.path),
            type: "ProfileImage",
          ) ??
          "";
      if (kDebugMode) {
        print("selected Image url:- ${profileImageURL.value}");
      }
    }
  }

  final _api = ConsumerProfileSetupRepository();

  @override
  void onInit() {
    super.onInit();
    locationController = Get.put(LocationController());
  }

  // Use current location to fill form fields
  Future<void> useCurrentLocation() async {
    try {
      // Ensure locationController is initialized
      if (!Get.isRegistered<LocationController>()) {
        locationController = Get.put(LocationController());
      }

      isLocationFetching.value = true;
      print("[CONSUMER PROFILE DEBUG] 🚀 Using current location...");

      bool success = await locationController.getCurrentLocationAndAddress();

      if (success) {
        // Populate the form fields with location data
        final addressComponents = locationController.addressComponents;

        // Set the street/address field
        if (addressComponents['street']?.isNotEmpty == true) {
          flatHouseController.text = addressComponents['street']!;
        } else if (addressComponents['fullAddress']?.isNotEmpty == true) {
          flatHouseController.text = addressComponents['fullAddress']!;
        }

        // Set other fields
        cityController.text = addressComponents['city'] ?? '';
        stateController.text = addressComponents['state'] ?? '';
        selectedCountry.value = addressComponents['country'] ?? '';
        countryController.text = addressComponents['country'] ?? '';
        pinCodeController.text = addressComponents['postalCode'] ?? '';

        print(
          "[CONSUMER PROFILE DEBUG] ✅ Form fields populated with location data",
        );
        print(
          "[CONSUMER PROFILE DEBUG] 📍 Coordinates: ${locationController.coordinates}",
        );

        // CustomToast.success('Location fetched successfully!');
      } else {
        print("[CONSUMER PROFILE DEBUG] ❌ Failed to get location data");
        CustomToast.error(
          'Failed to get location. Please check location services and permissions.',
        );
      }
    } catch (e) {
      print("[CONSUMER PROFILE DEBUG] ❌ Error in useCurrentLocation: $e");
      CustomToast.error('Error getting location: ${e.toString()}');
    } finally {
      isLocationFetching.value = false;
    }
  }

  // Get current latitude and longitude
  Map<String, double> get currentCoordinates => locationController.coordinates;

  void setSelectedCountry(String country) {
    selectedCountry.value = country;
  }

  Future<void> setupProfile() async {
    isLoading.value = true; // 🔄 Set loading state to true
    try {
      // Separate profile data from address data
      final profileData = {
        'name': nameController.text,
        'avatar': profileImageURL.value,
      };

      // Address data (will be stored in addresses table)
      final addressData = <String, dynamic>{
        'address_line1': flatHouseController.text,
        'city': cityController.text,
        'state': stateController.text,
        'postal_code': pinCodeController.text,
        'country': selectedCountry.value.isNotEmpty ? selectedCountry.value : 'United States',
        'is_default': true, // First address is default
      };
      
      // Add latitude/longitude only if they are valid
      if (locationController.latitude.value > 0) {
        addressData['latitude'] = locationController.latitude.value;
      }
      if (locationController.longitude.value > 0) {
        addressData['longitude'] = locationController.longitude.value;
      }

      // First, update the profile (name, avatar)
      final profileResponse = await _api.setupProfile(profileData);
      
      if (profileResponse['statusCode'] == 200) {
        // Then, create the address in the addresses table
        final apiServices = SupabaseApiServices();
        final addressResponse = await apiServices.addAddress(addressData);
        
        if (addressResponse['statusCode'] == 200 || addressResponse['statusCode'] == 201) {
          Get.put(ProviderController());
          CustomToast.success("Profile setup successful");
          AppRouterV2.goToNavBar(role: 'consumer');
        } else {
          // Profile updated but address failed - still show success but log warning
          print('[PROFILE SETUP] ⚠️ Profile updated but address creation failed: ${addressResponse['body']}');
          Get.put(ProviderController());
          CustomToast.success("Profile setup successful");
          AppRouterV2.goToNavBar(role: 'consumer');
        }
      } else {
        CustomToast.error(
          profileResponse['body']['message'] ?? "Profile setup failed",
        );
      }
    } catch (error) {
      CustomToast.error('Error setting up profile: $error');
      print('[PROFILE SETUP] ❌ Error: $error');
    } finally {
      isLoading.value = false; // 🔄 Set loading state to false
    }
  }
}
