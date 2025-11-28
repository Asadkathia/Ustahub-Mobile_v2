import 'package:get/get.dart';
import 'package:ustahub/app/modules/provider_details/model_class/provider_details_model_class.dart';

class PlanSelectionController extends GetxController {
  Rx<Service?> selectedService = Rx<Service?>(null);
  Rx<Plan?> selectedPlan = Rx<Plan?>(null);

  void selectServiceAndPlan(Service service, List<Plan> allPlans) {
    selectedService.value = service;
    // Filter plans for this service
    final plansForService =
        allPlans.where((p) => p.serviceId == service.id).toList();
    if (plansForService.isNotEmpty) {
      selectedPlan.value = plansForService.first;
    } else {
      selectedPlan.value = null;
    }
  }

  void selectPlan(Plan plan) {
    selectedPlan.value = plan;
  }

  void selectInitial(List<Service> services, List<Plan> allPlans) {
    if (services.isEmpty) {
      selectedService.value = null;
      selectedPlan.value = null;
      return;
    }

    final currentId = selectedService.value?.id;
    Service serviceToSelect =
        services.firstWhere(
          (service) => service.id == currentId,
          orElse: () => services.first,
        );
    selectServiceAndPlan(serviceToSelect, allPlans);
  }

  List<Plan> getPlansForSelectedService(List<Plan> allPlans) {
    if (selectedService.value == null) return [];
    return allPlans
        .where((p) => p.serviceId == selectedService.value!.id)
        .toList();
  }
}
