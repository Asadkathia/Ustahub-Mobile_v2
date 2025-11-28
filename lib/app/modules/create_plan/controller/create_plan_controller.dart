import 'package:ustahub/app/modules/create_plan/model/plan_model.dart';
import 'package:ustahub/app/modules/create_plan/repository/manage_plan_repository.dart';
import 'package:ustahub/app/modules/create_plan/repository/create_plan_repository.dart';
import 'package:ustahub/app/export/exports.dart';

class CreatePlanController extends GetxController {
  final ManagePlanRepository _manageRepo = ManagePlanRepository();

  Future<void> fetchAndPrefillPlans(String serviceId) async {
    final plansList = await _manageRepo.getPlans();
    // Filter for this service
    final filtered =
        plansList
            .where((e) => e['service_id'].toString() == serviceId)
            .toList();
    for (final planJson in filtered) {
      final plan = PlanModel.fromJson(planJson);
      int tabIndex = -1;
      final type = (plan.planType ?? '').toLowerCase();
      if (type == 'basic') {
        tabIndex = 0;
      } else if (type == 'standard' || type == 'standardd')
        tabIndex = 1;
      else if (type == 'premium')
        tabIndex = 2;
      if (tabIndex != -1) {
        plans[tabIndex].priceController.text = plan.planPrice ?? '';
        plans[tabIndex].titleController.text = plan.planTitle ?? '';
        plans[tabIndex].servicesControllers =
            plan.includedService
                .map((s) => TextEditingController(text: s))
                .toList();
        // Ensure at least one field for UI
        if (plans[tabIndex].servicesControllers.isEmpty) {
          plans[tabIndex].servicesControllers.add(TextEditingController());
        }
      }
    }
    update();
  }

  final CreatePlanRepository _repo = CreatePlanRepository();

  Future<void> addPlanForCurrentTab(String serviceId) async {
    final i = selectedTabIndex.value;
    final plan = plans[i];
    final planTitle = plan.titleController.text.trim();
    final planPrice = num.tryParse(plan.priceController.text.trim()) ?? 0;
    final includedService =
        plan.servicesControllers
            .map((e) => e.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
    final planType = tabs[i];

    if (planTitle.isEmpty || planPrice == 0 || includedService.isEmpty) {
      CustomToast.error("Please fill all fields for this plan");
      return;
    }

    final response = await _repo.addPlan(
      serviceId: serviceId,
      planTitle: planTitle,
      planPrice: planPrice,
      includedService: includedService,
      planType: planType,
    );
    if (response['body']['status'] == true) {
      CustomToast.success("Plan added successfully");
    } else {
      CustomToast.error(response['body']['message'] ?? 'Failed to add plan');
    }
  }

  void validateCurrentTab() {
    final i = selectedTabIndex.value;
    plans[i].price = plans[i].priceController.text.trim();
    plans[i].title = plans[i].titleController.text.trim();
    plans[i].services =
        plans[i].servicesControllers
            .map((e) => e.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();
    if (!plans[i].isComplete()) {
      CustomToast.error("Please fill all fields in ${tabs[i]} plan");
      return;
    }
    CustomToast.success("${tabs[i]} plan is valid!");
    // Proceed with saving or next step here
  }

  final tabs = ['Basic', 'Standard', 'Premium'];
  RxInt selectedTabIndex = 0.obs;

  List<PlanData> plans = List.generate(3, (_) => PlanData());

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void modifyService(int tabIndex, int serviceIndex) {
    final services = plans[tabIndex].servicesControllers;
    if (serviceIndex == services.length - 1) {
      // Add new service
      services.add(TextEditingController());
    } else {
      // Remove service
      services.removeAt(serviceIndex);
    }
    update();
  }

  void validateAllPlans() {
    for (int i = 0; i < plans.length; i++) {
      plans[i].price = plans[i].priceController.text.trim();
      plans[i].title = plans[i].titleController.text.trim();
      plans[i].services =
          plans[i].servicesControllers
              .map((e) => e.text.trim())
              .where((text) => text.isNotEmpty)
              .toList();

      if (!plans[i].isComplete()) {
        CustomToast.error("Please fill all fields in ${tabs[i]} plan");
        return;
      }
    }
    CustomToast.success("All plans are valid!");
  }
}

class PlanData {
  String price = '';
  String title = '';
  List<String> services = [];

  TextEditingController priceController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> servicesControllers = [TextEditingController()];

  bool isComplete() {
    return price.isNotEmpty && title.isNotEmpty && services.isNotEmpty;
  }
}
