import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_service_selection/repository/provider_service_selection_repository.dart';

class ProviderServiceSelectionController extends GetxController {
  var searchText = ''.obs;

  var selectedServices = <String>[].obs;
  var selectedServicesId = <String>[].obs;

  RxList<ServicesModelClass> serviceCategories = <ServicesModelClass>[].obs;
  RxBool isLoading = false.obs;

  final _api = ProviderServiceSelectionRepository();

  // ✅ Get service names (for debug or UI)
  List<String> getSelectedServiceList() {
    return selectedServices.toList();
  }

  // ✅ Get service IDs (for API submission)
  List<String> getSelectedServiceIds() {
    return selectedServicesId.toList();
  }

  // ✅ Filter services from API list
  List<ServicesModelClass> get filteredServices {
    final search = searchText.value.toLowerCase();
    return serviceCategories
        .where((service) => service.name!.toLowerCase().contains(search))
        .toList();
  }

  // ✅ Toggle service with both name and ID tracking
  void toggleService(String serviceName) {
    final service = serviceCategories.firstWhereOrNull(
      (s) => s.name == serviceName,
    );
    if (service == null) return;

    if (selectedServices.contains(serviceName)) {
      selectedServices.remove(serviceName);
      selectedServicesId.remove(service.id);
    } else if (selectedServices.length < 3) {
      selectedServices.add(serviceName);
      selectedServicesId.add(service.id!);
    }

    print("Selected Services: ${getSelectedServiceList()}");
    print("Selected IDs: ${getSelectedServiceIds()}");
  }

  // ✅ Allow selecting only up to 3
  bool isSelectable(String serviceName) {
    return selectedServices.contains(serviceName) ||
        selectedServices.length < 3;
  }

  // ✅ Initial fetch
  @override
  void onInit() {
    super.onInit();
    getServices();
  }

  // ✅ API call to fetch service categories
  void getServices() async {
    isLoading.value = true;
    try {
      final response = await _api.getServiceCategories();
      if (response['statusCode'] == 200) {
        List<dynamic> data = response['body']['services'];
        serviceCategories.value =
            data.map((item) => ServicesModelClass.fromJson(item)).toList();
      } else {
        CustomToast.error(
          response['body']['message'] ?? 'Failed to fetch services',
        );
      }
    } catch (e) {
      CustomToast.error('Error fetching services: $e');
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Add selected services to provider profile
  RxBool isAddingService = false.obs;

  void addService(bool isManageService) async {
    isAddingService.value = true;

    final serviceId = {'service_id': selectedServicesId};

    _api
        .addService(serviceId)
        .then((value) {
          if (value['statusCode'] == 200) {
            CustomToast.success('Services added successfully');
            if (!isManageService) {
              Get.offAll(() => ProviderProfileSetupView());
            } else {
              Get.back();
              
            }
            // Get.offAll(() => ProviderProfileSetupView());
          } else {
            CustomToast.error(
              value['body']['message'] ?? 'Failed to add services',
            );
          }
          isAddingService.value = false;
        })
        .catchError((error) {
          CustomToast.error('Error adding services: $error');
          isAddingService.value = false;
        });
  }
}
