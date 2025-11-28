import 'package:ustahub/network/supabase_api_services.dart';

class CreatePlanRepository {
  final _api = SupabaseApiServices();

  Future<dynamic> addPlan({
    required String serviceId,
    required String planTitle,
    required num planPrice,
    required List<String> includedService,
    required String planType,
  }) async {
    final response = await _api.createPlan(
      serviceId: serviceId,
      planTitle: planTitle,
      planPrice: planPrice,
      includedService: includedService,
      planType: planType,
    );
    return response;
  }
}
