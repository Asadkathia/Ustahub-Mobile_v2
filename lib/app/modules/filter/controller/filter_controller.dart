import 'package:get/get.dart';

enum FilterTab { service, rating }

class FilterController extends GetxController {
  final selectedFilterTab = FilterTab.service.obs;
  final allServices =
      <String>[].obs; // This will hold services fetched from API
  final selectedServices = <String>[].obs;
  final selectedRating = ''.obs; // 'lowest_to_high' or 'highest_to_low'


  void selectFilterTab(FilterTab tab) {
    selectedFilterTab.value = tab;
  }

  void toggleServiceSelection(String service) {
    if (selectedServices.contains(service)) {
      selectedServices.remove(service);
    } else {
      selectedServices.add(service);
    }
    selectedServices.refresh();
  }

  void applyFilters() {
    // TODO: Implement logic to apply filters based on selectedServices, selectedRating
    // This is where you would call your filter API
    Get.back(
      result: {
        'services': selectedServices.toList(),
        'rating': selectedRating.value,
      },
    );
  }

  void clearFilters() {
    selectedServices.clear();
    selectedRating.value = '';
    selectedFilterTab.value = FilterTab.service;
  }
}
