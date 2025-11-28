import 'package:ustahub/app/export/exports.dart';

class ServiceSelectionForPlanController extends GetxController {
  final _api = ServiceSelectionForPlanRepository();

  // Reactive variables
  RxBool isLoading = false.obs;
  RxList<ServicesModelClass> serviceList = <ServicesModelClass>[].obs;
  RxString selectedServiceName = "".obs;
  RxString selectedServiceId = "".obs;

  void selectService(String serviceName, String serviceId) {
    selectedServiceName.value = serviceName;
    selectedServiceId.value = serviceId;
    print(
      "[SERVICE PLAN DEBUG] Selected Service: $serviceName (ID: $serviceId)",
    );
  }

  Future<void> fetchMyServices() async {
    try {
      isLoading.value = true;
      print("[SERVICE PLAN DEBUG] 🔄 Fetching provider services...");

      final response = await _api.getMyServices();

      if (response['statusCode'] == 200) {
        final List<dynamic> servicesData = response['body']['services'];

        serviceList.value =
            servicesData
                .map((serviceJson) => ServicesModelClass.fromJson(serviceJson))
                .toList();

        print(
          "[SERVICE PLAN DEBUG] ✅ Services fetched successfully: ${serviceList.length} services",
        );

        // Print each service for debugging
        for (var service in serviceList) {
          print(
            "[SERVICE PLAN DEBUG] 📋 Service: ${service.name} (ID: ${service.id})",
          );
        }

        CustomToast.success("Services loaded successfully");
      } else {
        final errorMessage =
            response['body']['message'] ?? 'Failed to fetch services';
        CustomToast.error(errorMessage);
        print("[SERVICE PLAN DEBUG] ❌ API Error: $errorMessage");
      }
    } catch (e) {
      CustomToast.error("Error loading services: ${e.toString()}");
      print("[SERVICE PLAN DEBUG] ❌ Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh services (for pull-to-refresh)
  Future<void> refreshServices() async {
    await fetchMyServices();
  }

  // Get selected service object
  ServicesModelClass? get selectedService {
    if (selectedServiceId.value.isEmpty) return null;

    try {
      return serviceList.firstWhere(
        (service) => service.id.toString() == selectedServiceId.value,
      );
    } catch (e) {
      return null;
    }
  }

  // Check if a service is selected
  bool get hasSelectedService => selectedServiceId.value.isNotEmpty;

  // Clear selection
  void clearSelection() {
    selectedServiceName.value = "";
    selectedServiceId.value = "";
    print("[SERVICE PLAN DEBUG] 🧹 Service selection cleared");
  }

  @override
  void onInit() {
    super.onInit();
    fetchMyServices();
  }
}
