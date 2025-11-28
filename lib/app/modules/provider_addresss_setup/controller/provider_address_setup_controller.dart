import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/manage_address/repository/manage_address_repository.dart';
import 'package:ustahub/app/modules/location/controller/location_controller.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';

class ProviderAddressSetupController extends GetxController {
  final flatHouseController = TextEditingController();
  final pinCodeController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();

  var selectedCountry = "".obs;
  RxBool isLoading = false.obs;
  RxBool isLocationFetching = false.obs;

  // Location controller instance
  late LocationController locationController;

  final _api = ManageAddressRepository();

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
      print("[PROVIDER ADDRESS DEBUG] 🚀 Using current location...");

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
          "[PROVIDER ADDRESS DEBUG] ✅ Form fields populated with location data",
        );
        print(
          "[PROVIDER ADDRESS DEBUG] 📍 Coordinates: ${locationController.coordinates}",
        );

        // CustomToast.success('Location fetched successfully!');
      } else {
        print("[PROVIDER ADDRESS DEBUG] ❌ Failed to get location data");
        CustomToast.error(
          'Failed to get location. Please check location services and permissions.',
        );
      }
    } catch (e) {
      print("[PROVIDER ADDRESS DEBUG] ❌ Error in useCurrentLocation: $e");
      CustomToast.error('Error getting location: ${e.toString()}');
    } finally {
      isLocationFetching.value = false;
    }
  }

  // Get current latitude and longitude
  Map<String, double> get currentCoordinates => locationController.coordinates;

  void addAddress({required String role}) async {
    isLoading.value = true;
    print("Adding address...");

    final addressData = {
      'address_line1': flatHouseController.text,
      'postal_code': pinCodeController.text,
      'city': cityController.text,
      'state': stateController.text,
      'country': selectedCountry.value,
      'latitude': locationController.latitude.value,
      'longitude': locationController.longitude.value,
    };

    try {
      final value = await _api.addAddress(addressData: addressData, role: role);

      if (value['statusCode'] == 200 || value['statusCode'] == 201) {
        CustomToast.success("Address added successfully");
        Get.to(
          () => AppRouterV2.getNavBar(role: role, initialIndex: 0),
        );

        print(value);
      } else {
        CustomToast.error(value['body']['message'] ?? 'Failed to add address');
      }
    } catch (e) {
      CustomToast.error('Failed to add address');
      print('Error adding address: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
