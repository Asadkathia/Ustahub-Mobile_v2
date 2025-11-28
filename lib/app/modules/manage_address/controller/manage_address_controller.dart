import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/manage_address/model_class/address_model_class.dart';
import 'package:ustahub/app/modules/manage_address/repository/manage_address_repository.dart';
import 'package:ustahub/app/modules/location/controller/location_controller.dart';

class ManageAddressController extends GetxController {
  final flatHouseController = TextEditingController();
  final pinCodeController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();

  var selectedCountry = "".obs;

  final _api = ManageAddressRepository();

  // Location controller instance
  late LocationController locationController;

  RxBool isLoading = false.obs;
  RxBool isLocationFetching = false.obs;

  Future<void> addAddress() async {
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

    String? role =
        await Sharedprefhelper.getRole(); // Default to consumer if not provided

    try {
      final value = await _api.addAddress(
        addressData: addressData,
        role: role!,
      );

      if (value['statusCode'] == 200 || value['statusCode'] == 201) {
        CustomToast.success("Address added successfully");
        
        // Close the modal **before** updating state or calling getAddresses
        Get.back();
        
        // Clear form fields
        flatHouseController.clear();
        pinCodeController.clear();
        cityController.clear();
        stateController.clear();
        selectedCountry.value = "";
        
        // Refresh address list
        await Future.delayed(Duration(milliseconds: 300));
        getAddresses(role!);
      } else {
        final errorMessage = value['body']?['message'] ?? value['body']?['error'] ?? 'Failed to add address';
        CustomToast.error(errorMessage);
      }
    } catch (e) {
      CustomToast.error('Failed to add address');
      print('Error adding address: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    locationController = Get.put(LocationController());
    getRoleBySharedPref();
  }

  // Use current location to fill form fields
  Future<void> useCurrentLocation() async {
    try {
      // Ensure locationController is initialized
      if (!Get.isRegistered<LocationController>()) {
        locationController = Get.put(LocationController());
      }

      isLocationFetching.value = true;
      print("[ADDRESS DEBUG] 🚀 Using current location...");

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
        pinCodeController.text = addressComponents['postalCode'] ?? '';

        print("[ADDRESS DEBUG] ✅ Form fields populated with location data");
        print(
          "[ADDRESS DEBUG] 📍 Coordinates: ${locationController.coordinates}",
        );

        CustomToast.success('Location fetched successfully!');
      } else {
        print("[ADDRESS DEBUG] ❌ Failed to get location data");
        CustomToast.error(
          'Failed to get location. Please check location services and permissions.',
        );
      }
    } catch (e) {
      print("[ADDRESS DEBUG] ❌ Error in useCurrentLocation: $e");
      CustomToast.error('Error getting location: ${e.toString()}');
    } finally {
      isLocationFetching.value = false;
    }
  }

  // Get current latitude and longitude
  Map<String, double> get currentCoordinates => locationController.coordinates;

  void getRoleBySharedPref() async {
    String? role = await Sharedprefhelper.getRole();
    if (role != null) {
      getAddresses(role);
    } else {
      // CustomToast.error('Role not found in shared preferences');
    }
  }

  RxList<AddressModelClass> addressList = <AddressModelClass>[].obs;
  // Get addresses based on role
  void getAddresses(String role) async {
    isLoading.value = true;
    try {
      final response = await _api.getAddresses(role);
      if (response['statusCode'] == 200 && response['body']['status'] == true) {
        // Extract the data array from the nested structure
        final data = response['body']['data'] ?? [];
        List<dynamic> rawAddressList = data is List ? data : [];
        List<AddressModelClass> addresses =
            rawAddressList.map((item) => AddressModelClass.fromJson(item as Map<String, dynamic>)).toList();

        // Sort the list so that any isDefault == true is at index 0,
        // preserves order otherwise
        addresses.sort((a, b) {
          if (a.isDefault == true && b.isDefault != true) return -1;
          if (a.isDefault != true && b.isDefault == true) return 1;
          return 0; // Order does not change
        });

        addressList.value = addresses;
      } else {
        CustomToast.error(
          response['body']['message'] ?? 'Failed to fetch addresses',
        );
      }
    } catch (e) {
      CustomToast.error('Error fetching addresses: $e');
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Prefill the form with existing address data

  RxBool isEditMode = false.obs;

  void prefillAddressFields(AddressModelClass address) {
    flatHouseController.text = address.addressLine1 ?? '';
    pinCodeController.text = address.postalCode ?? '';
    cityController.text = address.city ?? '';
    stateController.text = address.state ?? '';
    selectedCountry.value = address.country ?? '';
  }

  void updateAddress(String addressId) async {
    isLoading.value = true;
    print("Updating address...");

    final addressData = {
      'address_line1': flatHouseController.text,
      'postal_code': pinCodeController.text,
      'city': cityController.text,
      'state': stateController.text,
      'country': selectedCountry.value,
    };

    String role = 'consumer'; // Default to consumer if not provided

    try {
      final response = await _api.updateAddress(
        addressId: addressId,
        addressData: addressData,
        role: role,
      );

      if (response['statusCode'] == 200) {
        CustomToast.success("Address updated successfully");

        // Close the modal **before** updating state or calling getAddresses
        Get.back();

        // Delay slightly to ensure modal is fully closed
        await Future.delayed(Duration(milliseconds: 300));

        getAddresses(role);
      } else {
        CustomToast.error(
          response['body']['message'] ?? 'Failed to update address',
        );
      }
    } catch (e) {
      CustomToast.error('Failed to update address');
      print('Error updating address: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete address
  void deleteAddress(String addressId) async {
    isLoading.value = true;
    print("Deleting address...");

    String role = 'consumer'; // Default to consumer if not provided

    try {
      final response = await _api.deleteAddress(
        addressId: addressId,
        role: role,
      );

      if (response['statusCode'] == 200) {
        CustomToast.success("Address deleted successfully");
        getAddresses(role);
      } else {
        CustomToast.error(
          response['body']['message'] ?? 'Failed to delete address',
        );
      }
    } catch (e) {
      CustomToast.error('Failed to delete address');
      print('Error deleting address: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    isLoading.value = true;
    print("Setting default address...");

    String? role = await Sharedprefhelper.getRole();
    if (kDebugMode) {
      if (role == null) {
        CustomToast.error('Role not found in shared preferences');
        isLoading.value = false;
        return;
      }
    }

    try {
      final response = await _api.setDefaultAddress(
        addressId: addressId,
        role: role!,
      );

      if (response['statusCode'] == 200) {
        CustomToast.success("Default address set successfully");
        getAddresses(role);
      } else {
        CustomToast.error(
          response['body']['message'] ?? 'Failed to set default address',
        );
      }
    } catch (e) {
      CustomToast.error('Failed to set default address');
      print('Error setting default address: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
