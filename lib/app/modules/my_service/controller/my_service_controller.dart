import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_service_selection/model_class/service_model_class.dart';
import 'package:ustahub/app/modules/provider_service_selection/repository/provider_service_selection_repository.dart';

class MyServiceController extends GetxController {
  final ProviderServiceSelectionRepository _repo = ProviderServiceSelectionRepository();
  final RxBool isLoading = false.obs;
  final RxList<ServicesModelClass> myServices = <ServicesModelClass>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyServices();
  }

  Future<void> fetchMyServices() async {
    isLoading.value = true;
    try {
      final res = await _repo.getMyServices();
      if (res['statusCode'] == 200 && res['body']?['services'] is List) {
        final list = (res['body']['services'] as List)
            .map((e) => ServicesModelClass.fromJson(e))
            .toList();
        myServices.assignAll(list);
      } else {
        CustomToast.error(res['body']?['message'] ?? 'Failed to load services');
      }
    } catch (e) {
      CustomToast.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
