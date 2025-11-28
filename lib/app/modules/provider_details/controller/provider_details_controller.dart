import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ustahub/app/modules/provider_details/controller/plan_selection_controller.dart';
import 'package:ustahub/app/modules/provider_details/controller/provider_ratings_controller.dart';
import 'package:ustahub/app/modules/provider_details/model_class/provider_details_model_class.dart';
import 'package:ustahub/app/modules/provider_details/repository/provider_details_repository.dart';

class ProviderDetailsController extends GetxController {
  var currentIndex = 0.obs;

  void updateIndex(int index) {
    currentIndex.value = index;
  }

  final _api = ProviderDetailsRepository();

  // Initialize provider ratings controller
  final ProviderRatingsController ratingsController = Get.put(
    ProviderRatingsController(),
  );

  Rxn<ProviderDetailsModelClass> providerDetails =
      Rxn<ProviderDetailsModelClass>();

  RxBool isLoading = false.obs;

  Future<void> getProviderById(String id) async {
    isLoading.value = true;
    // Clear previous data before loading new provider
    providerDetails.value = null;
    try {
      final response = await _api.getProviderById(id);
      debugPrint('[PROVIDER DETAILS] Response status: ${response['statusCode']}');
      debugPrint('[PROVIDER DETAILS] Response body keys: ${response['body']?.keys}');

      if (response['statusCode'] == 200 &&
          response['body'] != null &&
          response['body']['data'] != null) {
        final body = Map<String, dynamic>.from(response['body']['data']);
        debugPrint('[PROVIDER DETAILS] Body keys: ${body.keys}');
        debugPrint('[PROVIDER DETAILS] Profile name: ${body['name']}');
        debugPrint('[PROVIDER DETAILS] Providers data: ${body['providers']}');
        debugPrint('[PROVIDER DETAILS] Services count: ${(body['provider_services'] as List?)?.length ?? 0}');
        
        providerDetails.value = ProviderDetailsModelClass.fromJson(body);
        
        debugPrint('[PROVIDER DETAILS] Parsed provider name: ${providerDetails.value?.provider?.name}');
        debugPrint('[PROVIDER DETAILS] Parsed services count: ${providerDetails.value?.provider?.services.length}');

        final planController = Get.isRegistered<PlanSelectionController>()
            ? Get.find<PlanSelectionController>()
            : null;
        if (planController != null) {
          final services = providerDetails.value?.provider?.services ?? [];
          final plans = providerDetails.value?.provider?.plans ?? [];
          planController.selectInitial(services, plans);
        }

        await ratingsController.fetchProviderRatings(id);
      } else {
        debugPrint('[PROVIDER DETAILS] Error: $response');
        providerDetails.value = null;
      }
    } catch (e, stackTrace) {
      debugPrint('[PROVIDER DETAILS] Error fetching provider by ID: $e');
      debugPrint('[PROVIDER DETAILS] Stack trace: $stackTrace');
      providerDetails.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
